function gadget:GetInfo()
  return {
	name      = "Outpost - Aerofighter Control Tower",
	desc      = "Allows structures to order aircraft sorties.",
	author    = "Evil4Zerggin, Adapted by FLOZi",
	date      = "13 February 2008, Adapted 12/08/25",
	license   = "GNU GPL v2",
	layer     = 5, -- must be after outpost_dropZone.lua
	enabled   = true  --  loaded by default?
  }
end

if not gadgetHandler:IsSyncedCode() then return false end

local sqrt = math.sqrt
local max, sin, cos, atan2 = math.max, math.sin, math.cos, math.atan2

local CMD_PLANES = GG.CustomCommands.GetCmdID("CMD_PLANES")
local PATROL_DISTANCE = 1000
local FORMATION_SEPARATION = 128
local DIAG_FORMATION_SEPARATION = FORMATION_SEPARATION * sqrt(2)
local RETREAT_TOLERANCE = 64 --retreating planes disappear when they reach this distance from the map edge
local CRUISE_SPEED = 0.75
local PLANE_STATE_ACTIVE = 0
local PLANE_STATE_RETREAT = 1
local DEPOSIT_AMOUNT = 0.65
local PENALTY_AMOUNT = 0.1

-- a scout plane can cover 24 map squares on a 'normal' tank of gas (60 seconds).
-- this becomes a reference point for how much to scale fuel amounts based on
-- map size. We add a 25% bump so the planes have some time to do their work
-- once they arrive. The formula is:
-- (mapDiagonalLength / REFERENCE_FUEL_AMOUNT) * definedPlaneFuel
local REFERENCE_FUEL_AMOUNT = 17
local DEFAULT_FUEL = 60

local CreateUnit = Spring.CreateUnit
local DestroyUnit = Spring.DestroyUnit
local SetUnitPosition = Spring.SetUnitPosition
local SetUnitRotation = Spring.SetUnitRotation
local SetUnitVelocity = Spring.SetUnitVelocity
local AddTeamResource = Spring.AddTeamResource
local UseTeamResource = Spring.UseTeamResource
local GetTeamResources = Spring.GetTeamResources
local GetTeamStartPosition = Spring.GetTeamStartPosition
local GetUnitCmdDescs = Spring.GetUnitCmdDescs
local EditUnitCmdDesc = Spring.EditUnitCmdDesc
local InsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local UseUnitResource = Spring.UseUnitResource
local GetUnitIsStunned = Spring.GetUnitIsStunned
local GetUnitDefID = Spring.GetUnitDefID
local GetUnitTeam = Spring.GetUnitTeam
local GetUnitPosition = Spring.GetUnitPosition
local GetUnitHealth = Spring.GetUnitHealth
local GetGameFrame = Spring.GetGameFrame
local GetGroundHeight = Spring.GetGroundHeight
local SendMessageToTeam = Spring.SendMessageToTeam


local GetTeamRulesParam = Spring.GetTeamRulesParam
local SetTeamRulesParam = Spring.SetTeamRulesParam
local GetUnitRulesParam = Spring.GetUnitRulesParam
local SetUnitRulesParam = Spring.SetUnitRulesParam

local vNormalized
local vRotateY
local vClampToMapSize
local vNearestMapEdge
local vDistanceToMapEdge

local DelayCall

local SetUnitNoSelect = Spring.SetUnitNoSelect
local GiveOrderToUnit = Spring.GiveOrderToUnit

local mapSizeX, mapSizeZ = Game.mapSizeX, Game.mapSizeZ
local mapX, mapY = Game.mapX, Game.mapY

local CMD_IDLEMODE = CMD.IDLEMODE
local CMD_AUTOREPAIRLEVEL = CMD.AUTOREPAIRLEVEL
local CMD_MOVE = CMD.MOVE
local CMD_FIGHT = CMD.FIGHT
local CMD_PATROL = CMD.PATROL
local CMD_ATTACK = CMD.ATTACK
local CMD_OPT_SHIFT = CMD.OPT_SHIFT

-- Menus
local typeStrings = {"order", "deploy"}--, "support"}
local typeStringIndex = {}
for i, v in ipairs(typeStrings) do
	typeStringIndex[v] = i
end
local typeStringAliases = { 
	["order"] 	= GG.Pad(10,"Order", "Aeros"),
	["deploy"] 	= GG.Pad(10,"Deploy", "Sorties"), 
	--["support"] = GG.Pad(10,"Support", "VTOL"), 
}

local aeroMenuCmdDescs = {}
local menuCmdIDs = {}
for i, typeString in ipairs(typeStrings) do
	local cmdID = GG.CustomCommands.GetCmdID("CMD_MENU_" .. typeString:upper())
	aeroMenuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = typeStringAliases[typeString],
		action = 'menu' .. typeString,
		tooltip = "Switch menu to " .. typeStringAliases[typeString]:gsub("%s+\n", " "),
		texture = 'bitmaps/ui/filter.png',
	}
	menuCmdIDs[cmdID] = typeString
end
menuCmdIDs[GG.CustomCommands.GetCmdID("CMD_RUNNING_TOTAL")] = "previous"
menuCmdIDs[GG.CustomCommands.GetCmdID("CMD_RUNNING_TONS")] = "next"
menuCmdIDs.n = #typeStrings
local menuTypeCache = {}

-- Sorties
local AIRCON_UD = UnitDefNames["outpost_aircon"]
local aeroCache = {}
GG.aeroCache = aeroCache -- just in case

--local sideSortieCmdDescs = {}
local sortieDefs = {}
local sortieCmdIDs = {} --cmdID = { unitDefID, unitDefID... name, units, delay, cmdDesc }

local teamSorties = {} -- [teamID][unitDefID] = {active = number, offscreen = number} -- offscreen = ordered + returning + inbound
local teamAvailableSortieSlots = {} -- teamID = number
GG.teamAvailableSortieSlots = teamAvailableSortieSlots

local function GetDefaultTooltip(sortie, sortieUnitDef)
	local planeList = {}
	local duration = 0
	local sortieMembers = sortie.members
	for i=1,#sortieMembers do
		local unitDef = UnitDefNames[sortieMembers[i]]
		if unitDef then
			local fuel = tonumber(unitDef.customParams.maxfuel) or DEFAULT_FUEL
			if fuel > 0 and duration then
				if fuel > duration then
					duration = fuel
				end
			else
				duration = nil
			end
		end
	end

	local result = "Call " .. sortieUnitDef.humanName .. " - " .. sortieUnitDef.tooltip .. "\n"
		.. "Delay " .. (sortie.entryDelay or 0) .. "s\n"
		.. "Duration " .. (duration or "Permanent") .. "s"

	return result
end

-- TODO: this is copy pasta from L208 outpost_dropZone.lua LockHeavy function, generalise it?
local locked = {} -- unitID[unitDefID] = true

local function LockAssault(acID, lock) 
	local cmdDescs = GetUnitCmdDescs(acID)
	locked[acID] = locked[acID] or {}
	for i = 1, #cmdDescs do
		local defID = cmdDescs[i].id
		--if defID > 0 then Spring.Echo("UMM?", sortieCmdIDs[defID] and sortieCmdIDs[defID].name) end
		local class = (defID < 0 and tonumber(UnitDefs[-defID].customParams.unlocklevel or 0)) or (sortieCmdIDs[defID] and tonumber(sortieCmdIDs[defID].unlockLevel or 0))
		--Spring.Echo("YOYO", class)--defID < 0 and tonumber(UnitDefs[-defID].customParams.unlocklevel or 0))
		if class == 2 then
			--Spring.Echo("Hiding", defID < 0 and UnitDefs[-defID].name or sortieCmdIDs[defID] and sortieCmdIDs[defID].name, lock)
			locked[acID][math.abs(defID)] = lock
			EditUnitCmdDesc(acID, i, {hidden = lock})		
		end
	end
	GG.ShowBuildOptionsByType(acID, "order", menuTypeCache, menuCmdIDs, typeStringIndex, locked[acID])
end
GG.LockAssault = LockAssault

local function GenerateSortie(unitDefID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	local sortie = {}
	local newLine = unitDef.description:find("\n")
	sortie.name = unitDef.description:sub(1, newLine and newLine-1 or unitDef.description:len())
	
	local cmdID = GG.CustomCommands.GetCmdID("CMD_PLANES_" .. unitDefID)
	menuTypeCache[cmdID] = "deploy"

	sortie.members = {unitDef.name} -- TODO: get rid of this?
	sortie.weight = cp.weight or 1 -- TODO: and this?
	
	sortie.entryDelay = cp.entrydelay or 15
	sortie.prepDelay = cp.prepdelay or 15
	sortie.groundOnly = cp.groundonly
	sortie.alwaysAttack = cp.alwaysattack
	sortie.spawnAtTarget = cp.spawnattarget
	sortie.unlockLevel = cp.unlocklevel

	sortie.cmdDesc = {
		id = cmdID,
		action = "sortie_" .. unitDef.name,
		name = "0\n ",
		disabled = true,
		cursor = "Attack",
		tooltip = GetDefaultTooltip(sortie, unitDef),
		texture = "unitpics/" .. unitDef.buildpicname,
		type = sortie.groundOnly and CMDTYPE.ICON_MAP or CMDTYPE.ICON_UNIT_OR_MAP,
	}
	sortieCmdIDs[cmdID] = sortie
	sortieDefs[unitDefID] = sortie
	local side = unitDef.name:sub(1,2)
	--sideSortieCmdDescs[side] = sideSortieCmdDescs[side] or {}
	--sideSortieCmdDescs[side][unitDefID] = sortie.cmdDesc
end


local planeStates = {} --unitID = state
local radios = {} --teamID = { unitID = true, unitID = true, unitID = true... }

local statusText = {
	active 	= "Active    ",
	prep 	= "Prepping ",
	inbound = "Inbound  ",
	ready 	= "Ready    ",
	none 	= "Available",
}

local function UpdateCMDs(teamID, sortie, stockpile, status)
	local cmdID = sortie.cmdDesc.id
	--local rulesParamName = "game_planes.stockpile" .. cmdID
	--local stockpile = GetTeamRulesParam(teamID, rulesParamName) or 0
	--local stockpile = teamSorties[teamID][-cmdID][status] or 0
	local disabled = status ~= "ready"
	if stockpile and stockpile > 0 then 
		status = status == "none" and "active" or status
	else
		stockpile = 0
	end 
	local editTable = {
		name = stockpile .. "\n" .. statusText[status],
		disabled = disabled,
	}

	for unitID, _ in pairs(radios[teamID]) do
		local cmdDescs = GetUnitCmdDescs(unitID)
		for i = 1, #cmdDescs do
			local cmdDesc = cmdDescs[i]
			if cmdDesc.id == cmdID then
				EditUnitCmdDesc(unitID, i, editTable)
			end
		end
	end
end

local function GetStockPile(teamID, sortie, status)
	local cmdID = sortie.cmdDesc.id
	--local rulesParamName = "game_planes.stockpile" .. cmdID
	--return GetTeamRulesParam(teamID, rulesParamName) or 0
	return teamSorties[teamID][-cmdID][status] or 0
end

local function ModifyStockpile(teamID, sortie, amount, oldState, newState)
	if select(3, Spring.GetTeamInfo(teamID)) then -- Team is dead
		return
	end
	local cmdID = sortie.cmdDesc.id
	if oldState then -- may be brand spankin' new
		teamSorties[teamID][-cmdID][oldState] = teamSorties[teamID][-cmdID][oldState] - amount -- attempt to index nil
	elseif not teamSorties[teamID][-cmdID] then  -- first time, setup
		teamSorties[teamID][-cmdID] = {
			active = 0,
			prep = 0,
			inbound = 0,
			ready = 0,
		}
		teamAvailableSortieSlots[teamID] = teamAvailableSortieSlots[teamID] - amount
	end
	if newState then -- not dieing
		teamSorties[teamID][-cmdID][newState] = teamSorties[teamID][-cmdID][newState] + amount
		if newState == "ready" then
			Script.LuaRules.SortieReady(teamID, cmdID) -- let AI know
		end
	else
		teamAvailableSortieSlots[teamID] = teamAvailableSortieSlots[teamID] + amount
	end
	Spring.SetTeamRulesParam(teamID, "TEAM_AERO_SLOTS_REMAINING", teamAvailableSortieSlots[teamID])
	UpdateCMDs(teamID, sortie, teamSorties[teamID][-cmdID][newState] or teamSorties[teamID][-cmdID][oldState], newState or "none")
end

----------------------------------------------------------------
--spawning
----------------------------------------------------------------

local function SpawnPlane(teamID, unitname, sx, sy, sz, cmdParams, dx, dy, dz, rotation, waypoint, numInFlight, alwaysAttack, spawnAtTarget)
	if #cmdParams == 3 then
		cmdParams[1], cmdParams[2], cmdParams[3] = vClampToMapSize(cmdParams[1], cmdParams[2], cmdParams[3])
	end

	local unitDef = UnitDefNames[unitname]
	--local speed = unitDef.speed / 30
	local speed = 20
    -- 1.5x looks a bit better (otherwise they come in too low and sharply rise
    -- right after spawning)
	local altitude = unitDef.wantedHeight * 1.5

    -- don't count underwater valleys as low terrain for altitude purposes
    if sy < 0 then
        sy = 0
    end

	sy = sy + (spawnAtTarget and 0 or altitude)
	local unitID = CreateUnit(unitname, sx, sy, sz, 0, teamID)

	if unitID ~= nil then
		-- scale plane fuel to map size (roughly)
		local mapDiagonalLength = math.sqrt(mapX ^ 2 + mapY ^ 2)
		local fuelBoost = mapDiagonalLength / REFERENCE_FUEL_AMOUNT
		local currentFuel = tonumber(unitDef.customParams.maxfuel) or DEFAULT_FUEL
		SetUnitRulesParam(unitID, "fuel", fuelBoost * currentFuel)

		if not spawnAtTarget then
			SetUnitPosition(unitID, sx, sy, sz)
			SetUnitVelocity(unitID, dx * speed, dy * speed, dz * speed)
			SetUnitRotation(unitID, 0, -rotation, 0) --SetUnitRotation uses left-handed convention
		end
		GiveOrderToUnit(unitID, CMD_IDLEMODE, {0}, {}) --no land
		if alwaysAttack then
			GiveOrderToUnit(unitID, CMD_ATTACK, cmdParams, {})
			--[[if waypoint then
			  GiveOrderToUnit(unitID, CMD_PATROL, waypoint, {"shift"})
			end]]
		else
			if #cmdParams == 1 then --specific target: attack it, then patrol to waypoint
				GiveOrderToUnit(unitID, CMD_ATTACK, cmdParams, {"shift"})
				if waypoint then
					GiveOrderToUnit(unitID, CMD_PATROL, waypoint, {"shift"})
				end
			else --location: fight to waypoint, then patrol to target
				if waypoint then
					GiveOrderToUnit(unitID, CMD_FIGHT, waypoint, {"shift"})
				end
				GiveOrderToUnit(unitID, CMD_PATROL, cmdParams, {"shift"})
			end
		end
		planeStates[unitID] = PLANE_STATE_ACTIVE
		-- make the plane say something if it's the first in its group
		if numInFlight==1 then
			if unitDef.customParams.planevoice then
				local env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.PlaneVoice, 'enter_map')
			end
		end
		-- remove fly/land and land at x buttons
		local toRemove = {CMD_IDLEMODE, CMD_AUTOREPAIRLEVEL}
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
		end
	end
end

local function GetFormationOffsets(numUnits, rotation)
	local result = {}
	if numUnits == 1 then
		result[1] = {0, 0, 0}
	elseif numUnits == 2 then
		result[1] = {vRotateY(-FORMATION_SEPARATION, 0, 0, rotation)}
		result[2] = {vRotateY(FORMATION_SEPARATION, 0, 0, rotation)}
	else
		local i = 1
		local pairNum = 0
		while true do
			result[i] = {vRotateY(-DIAG_FORMATION_SEPARATION * pairNum, 0, -DIAG_FORMATION_SEPARATION * pairNum, rotation)}
			i = i + 1
			pairNum = pairNum + 1
			if i > numUnits then break end

			result[i] = {vRotateY(DIAG_FORMATION_SEPARATION * pairNum, 0, -DIAG_FORMATION_SEPARATION * pairNum, rotation)}
			i = i + 1
			if i > numUnits then break end
		end
	end

	return result
end

local function SpawnFlight(teamID, sortie, sx, sy, sz, cmdParams, stockpile)
	local tx, ty, tz
	if #cmdParams == 1 then
		tx, ty, tz = GetUnitPosition(cmdParams[1])
		if not tx then
			tx, ty, tz = GetTeamStartPosition(teamID)
			cmdParams = {tx, ty, tz}
		end
	else
		tx, ty, tz = cmdParams[1], cmdParams[2], cmdParams[3]
	end

	local dx, dy, dz, dist = vNormalized(tx - sx, 0, tz - sz)
	local rotation = atan2(dx, dz)

	local sortieMembers = sortie.members
	local offsets = GetFormationOffsets(stockpile, rotation)
	if sortie.spawnAtTarget then
		for i=1, stockpile do --#sortieMembers do
			SpawnPlane(teamID, sortieMembers[1], tx+math.random(100), ty, tz+math.random(100), cmdParams, dx, dy, dz, rotation, nil, i, sortie.alwaysAttack, true)	
		end
	elseif dist >= PATROL_DISTANCE then
		local wbx, wbz = sx + (dist - PATROL_DISTANCE) * dx, sz + (dist - PATROL_DISTANCE) * dz
		for i=1, stockpile do --#sortieMembers do
			local offset = offsets[i]
			local waypoint = {}
			waypoint[1], waypoint[2], waypoint[3] = offset[1] + wbx, 0, offset[3] + wbz
			local ux, uz = offset[1] + sx, offset[3] + sz
			local uy = GetGroundHeight(ux, uz)
			local unitname = sortieMembers[1]
			SpawnPlane(teamID, unitname, ux, uy, uz, cmdParams, dx, dy, dz, rotation, waypoint, i, sortie.alwaysAttack)
		end
	else
		for i=1, stockpile do --#sortieMembers do
			local offset = offsets[i]
			local ux, uz = offset[1] + sx, offset[3] + sz
			local uy = GetGroundHeight(ux, uz)
			local unitname = sortieMembers[1]
			SpawnPlane(teamID, unitname, ux, uy, uz, cmdParams, dx, dy, dz, rotation, waypoint, i, sortie.alwaysAttack)
		end
	end

	GG.PlaySoundForTeam(teamID, "bb_outpost_aircon_deploying", 1)
	SendMessageToTeam(teamID, sortie.name .. " arrived.")
	ModifyStockpile(teamID, sortie, stockpile, "inbound", "active")
	
	if not sortie.silent then
		local allyTeam = select(6, Spring.GetTeamInfo(teamID))
		for _, alliance in ipairs(Spring.GetAllyTeamList()) do
			if alliance ~= allyTeam then
				-- assumes all aircraft in a sortie are the same
				--Spring.SendMessageToAllyTeam(alliance, "\255\255\001\001Enemy " .. UnitDefNames[sortieMembers[1]].humanName .. " aircraft spotted overhead!")
			end
		end
	end
end

local function GetSpawnPoint(teamID, numPlanes)
	local margin = FORMATION_SEPARATION * 0.5 * (numPlanes or 0)
	local sx, sy, sz = GetTeamStartPosition(teamID)
	local rx, ry, rz = vNearestMapEdge(sx, sy, sz, margin)
	return rx, ry, rz
end

----------------------------------------------------------------
--callins
----------------------------------------------------------------

local sideAeroDefs = {}

function gadget:Initialize()
	vNormalized = GG.Vector.Normalized
	vRotateY = GG.Vector.RotateY
	vClampToMapSize = GG.Vector.ClampToMapSize
	vNearestMapEdge = GG.Vector.NearestMapEdge
	vDistanceToMapEdge = GG.Vector.DistanceToMapEdge

	DelayCall = GG.Delay.DelayCall

	for _, teamID in pairs(Spring.GetTeamList()) do
		radios[teamID] = {}
		teamSorties[teamID] = {}
		teamAvailableSortieSlots[teamID] = 6
	end

	for unitDefID, unitDef in pairs(UnitDefs) do
		local cp = unitDef.customParams
		if cp.baseclass and cp.baseclass == "aero" then
			local side = unitDef.name:sub(1,2)
			--Spring.Echo("Init: found an aero", side, unitDef.name)
			aeroCache[unitDefID] = true
			sideAeroDefs[side] = sideAeroDefs[side] or {}
			sideAeroDefs[side][unitDefID] = true
			GenerateSortie(unitDefID)
		end
	end

	for i, buildDefID in pairs(AIRCON_UD.buildOptions) do
		menuTypeCache[buildDefID] = "order"
		--[[local sortie = sortieDefs[buildDefID]
		if sortie then
			sortieCmdDescs[#sortieCmdDescs+1] = sortie.cmdDesc
		end

		if #sortieCmdDescs > 0 then
			radioDefs[AIRCON_UD.id] = sortieCmdDescs
		end]]
	end
	-- support /luarules reload
	local allUnits = Spring.GetAllUnits()
	for i=1, #allUnits do
		local unitID = allUnits[i]
		local unitDefID = GetUnitDefID(unitID)
		local teamID = GetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

local toRemove = {CMD.IDLEMODE, CMD.AUTOREPAIRLEVEL}
		
function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	-- Remove aircraft land and repairlevel buttons
	if ud.canFly then 
		if aeroCache[unitDefID] and not cp.spawnattarget then
			local strafeDistance = tonumber(cp.strafeDistance or 500)
			local strafeOvertime = tonumber(cp.strafeOvertime or 1000)
			Spring.MoveCtrl.SetAirMoveTypeData(unitID, "attackSafetyDistance", strafeDistance)
			Spring.MoveCtrl.SetAirMoveTypeData(unitID, "maneuverBlockTime", strafeOvertime)
		end
		Spring.GiveOrderToUnit(unitID, CMD.IDLEMODE, {0}, {})
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			if cmdDescID then
				Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
			end
		end
	end
	if unitDefID ~= AIRCON_UD.id then return end
	
	-- It's an aircon, initialize it
	radios[teamID][unitID] = true
	locked[unitID] = {}
	GG.ClearCmdDescs(unitID, true)
	GG.AddBuildMenu(unitID, aeroMenuCmdDescs)
	GG.orderStatus[unitID] = 0
	-- Remove all aero units that do not belong to the team's side
	local side = GG.teamSide[teamID]
	if not side then return end -- presume team is dead
	local toDelete = {}
	for i, cmdDesc in pairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id < 0 then
			if not (sideAeroDefs[side][-cmdDesc.id]) then -- or sortieDefs[-cmdDesc.id]) then
				toDelete[cmdDesc.id] = true
			else
				-- add in the deploy sortie cmddescs
				local sortie = sortieDefs[-cmdDesc.id]
				local sortieCmdDesc = sortie.cmdDesc

				local stockpile = teamSorties[teamID][-sortieCmdDesc.id] or {} -- TODO: uh, how is it nil?
				local highestPile = 0
				local highestStage = "none"
				for stage, pile in pairs(stockpile) do
					--Spring.Echo("PARP!", stage, pile)
					if pile > highestPile then
						highestPile = pile
						highestStage = stage
					end
				end
				sortieCmdDesc.name = highestPile .. "\n" .. statusText[highestStage]
				if sortie.unlockLevel then
					--Spring.Echo("PARP found a locked sortie", sortie.name, sortie.unlockLevel)
					locked[unitID][sortieCmdDesc.id] = true
				end
				sortieCmdDesc.disabled = not (highestPile > 0)
				GG.Delay.DelayCall(InsertUnitCmdDesc,{unitID, sortieCmdDesc}, 1) -- so that unit-perks populates upgrades first
			end
		end
	end
	for cmdID in pairs(toDelete) do
		Spring.RemoveUnitCmdDesc(unitID, Spring.FindUnitCmdDesc(unitID, cmdID))
	end
	GG.Delay.DelayCall(LockAssault, {unitID, true}, 1) -- ditto
end


local function SendPurchaseOrder(cost, weight, unitID, unitDefID, teamID)
	local orderQueue = Spring.GetFullBuildQueue(unitID)
	if not orderQueue then 
		return 
	end
	if #orderQueue > 0 then -- proceed with order
		Spring.SendMessageToTeam(teamID, "Sending purchase order for the following:")
		for i, order in ipairs(orderQueue) do
			for orderDefID, count in pairs(order) do
				Spring.SendMessageToTeam(teamID, UnitDefs[orderDefID].humanName .. ":\t" .. count)
				local sortie = sortieDefs[orderDefID]
				ModifyStockpile(teamID, sortie, count, nil, "prep")
				GG.PlaySoundForTeam(teamID, "bb_outpost_aircon_preparing", 1)
				GG.Delay.DelayCall(GG.PlaySoundForTeam, {teamID, "bb_outpost_aircon_ready", 1}, sortie.prepDelay * 30) -- TODO: this will play multiple times...
				GG.Delay.DelayCall(ModifyStockpile, {teamID, sortie, count, "prep", "ready"}, sortie.prepDelay * 30)
			end
		end
	else -- cancelled
		Spring.SendMessageToTeam(teamID, "Order cancelled, queue is empty")
	end
	-- clean up (regardless of whether or not order was fulfilled or cancelled)
	GG.OrderFinished(unitID, teamID)
	GG.CleanupOrder(unitID, teamID)
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	--planes
	local planeState = planeStates[unitID]
	if planeState == PLANE_STATE_RETREAT or (planeState and cmdID == CMD_IDLEMODE) then
		return false
	end
	
	-- check if unit is a radio
	if not radios[teamID][unitID] then
		return true
	end
	
	-- check if command is a sortie
	local sortie = sortieCmdIDs[cmdID]
	if not sortie then
		return GG.PurchaseOrders(unitID, unitDefID, teamID, cmdID, cmdOptions, SendPurchaseOrder, menuTypeCache, menuCmdIDs, typeStrings, typeStringIndex, teamAvailableSortieSlots[teamID], locked[unitID])
	end
	
	local _, _, inBuild = GetUnitIsStunned(unitID)
	if inBuild then
	  -- can't order
	else
		local stockpile = teamSorties[teamID][-cmdID].ready-- GetStockpile(teamID, sortie, "ready")
		if stockpile > 0 then
			ModifyStockpile(teamID, sortie, stockpile, "ready", "inbound")
			local sx, sy, sz = GetSpawnPoint(teamID, #sortie.members)
			DelayCall(SpawnFlight, {teamID, sortie, sx, sy, sz, cmdParams, stockpile}, sortie.entryDelay * 30)
			SendMessageToTeam(teamID, sortie.name .. " sortie ordered. ETA " .. (sortie.entryDelay or 0) .. "s.")
			--[[local allyTeam = select(6, Spring.GetTeamInfo(teamID))
			for _, alliance in ipairs(Spring.GetAllyTeamList()) do
				if alliance ~= allyTeam and sortie.weight > 0 and not sortie.silent then
					Spring.SendMessageToAllyTeam(alliance, "\255\255\001\001Incoming enemy aircraft on radar, arriving in " .. sortie.entryDelay .. " seconds")
				end
			end]]
			return true
		else
			SendMessageToTeam(teamID, "Sortie not available.")
			return false
		end
	end

	return true --false
end

local function RetreatPlane(unitID, unitDefID, teamID)
	local hpLeft, totalHp = GetUnitHealth(unitID)
	--local deposit = (unitDef.customParams.deposit or DEPOSIT_AMOUNT) * unitDef.metalCost
	--local depositReturn = (hpLeft / totalHp) * deposit
	--AddTeamResource(teamID, "m", depositReturn)
	planeStates[unitID] = nil --this looks redundant, but needs to happen so that you actually get your bonus.
	local sortie = sortieDefs[unitDefID]
	GG.PlaySoundForTeam(teamID, "bb_outpost_aircon_preparing", 1) -- TODO: this will play multiple times
	ModifyStockpile(teamID, sortie, 1, "active", "prep")
	GG.Delay.DelayCall(GG.PlaySoundForTeam, {teamID, "bb_outpost_aircon_ready", 1}, sortie.prepDelay * 30) -- TODO: this will play multiple times...
	GG.Delay.DelayCall(ModifyStockpile, {teamID, sortie, 1, "prep", "ready"}, sortie.prepDelay * 30)
	DestroyUnit(unitID, false, true)
end
GG.RetreatPlane = RetreatPlane -- called by Avenger on a rocket burn out

function gadget:GameFrame(n)
	for unitID, state in pairs(planeStates) do
		local unitDefID = GetUnitDefID(unitID)
		local unitDef = UnitDefs[unitDefID]
		local teamID = GetUnitTeam(unitID)
		local fuel = GetUnitRulesParam(unitID, "fuel")
		if fuel and state and state == PLANE_STATE_ACTIVE then -- TODO: why is avenger breaking this?
			if fuel < 1 and (tonumber(unitDef.customParams.maxfuel) or DEFAULT_FUEL) > 0 then
				SetUnitNoSelect(unitID, true)
				-- give fuel back so that it can fly to map border
				SetUnitRulesParam(unitID, "fuel", (tonumber(unitDef.customParams.maxfuel) or DEFAULT_FUEL))
				-- check if we can rocket out
				env = Spring.UnitScript.GetScriptEnv(unitID)
				if env.TakeOffThread then
					Spring.UnitScript.CallAsUnit(unitID, env.TakeOffThread) -- TakeOff will call RetreatPlane
				else
					local ex, ey, ez = GetSpawnPoint(teamID)
					GiveOrderToUnit(unitID, CMD_MOVE, {ex, ey, ez}, {})
					planeStates[unitID] = PLANE_STATE_RETREAT	
				end
				-- make it say something
				GG.PlaySoundForTeam(teamID, "bb_outpost_aircon_returning", 1)
				if unitDef.customParams.planevoice then
					local env = Spring.UnitScript.GetScriptEnv(unitID)
					Spring.UnitScript.CallAsUnit(unitID, env.PlaneVoice, 'return_to_base')
				end
			else
				SetUnitRulesParam(unitID, "fuel", max(0, fuel - 0.033))
			end
		elseif fuel and state and state == PLANE_STATE_RETREAT then
			-- check that it has enough fuel for return at all times
			if fuel < 2 and (tonumber(unitDef.customParams.maxfuel) or DEFAULT_FUEL) > 0 then
				SetUnitRulesParam(unitID, "fuel", (tonumber(unitDef.customParams.maxfuel) or DEFAULT_FUEL))
			end
			local ux, uy, uz = GetUnitPosition(unitID)
			if vDistanceToMapEdge(ux, uy, uz) <= RETREAT_TOLERANCE then
				RetreatPlane(unitID, unitDefID, teamID)
			end
		end
	end
	if n > 0 and n % 30 == 0 then -- once a second
		-- check if orders are still too expensive
		for teamID, list in pairs(radios) do
			for unitID in pairs(list) do
				GG.CheckBuildOptions(unitID, teamID, teamAvailableSortieSlots[teamID])
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if planeStates[unitID] then -- aircraft was killed, not retreating
		local unitDef = UnitDefs[unitDefID]
		AddTeamResource(teamID, "e", unitDef.energyCost)
		--local curCommand = GetTeamResources(teamID, "metal")
		--local penalty = math.min((unitDef.customParams.penalty or PENALTY_AMOUNT) * unitDef.metalCost, curCommand)
		--UseTeamResource(teamID, "m", penalty)s
		--teamAvailableSortieSlots[teamID] = teamAvailableSortieSlots[teamID] + 1
		local sortie = sortieDefs[unitDefID]
		ModifyStockpile(teamID, sortie, 1, "active", nil)
	end
	planeStates[unitID] = nil
	radios[teamID][unitID] = nil
	locked[unitID] = nil
end

function gadget:AllowUnitBuildStep(builderID, builderTeam, unitID, unitDefID, part)
	if radios[builderTeam][builderID] then
		return false
	end
	return true
end

--[[function TransferStockpiles(oldTeamID, newTeamID) -- TODO
	for _, sortie in pairs(sortieDefs) do
		local cmdID = sortie.cmdDesc.id
		local rulesParamName = "game_planes.stockpile" .. cmdID
		local stockpile = GetTeamRulesParam(oldTeamID, rulesParamName) or 0
		ModifyStockpile(oldTeamID, sortie, -stockpile)
		ModifyStockpile(newTeamID, sortie, stockpile)
	end
end]]

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if radios[oldTeam][unitID] then
		radios[oldTeam][unitID] = nil
		if next(radios[oldTeam]) == nil then
			--TransferStockpiles(oldTeam, newTeam)
		end
	end
end

function gadget:UnitTaken(unitID, unitDefID, oldTeam, newTeam)
	local _, _, inBuild = GetUnitIsStunned(unitID)
	if inBuild then
		gadget:UnitCreated(unitID, unitDefID, newTeam)
	else
		if unitDefID == AIRCON_UD.id then
			radios[newTeam][unitID] = true
		end
		gadget:UnitCreated(unitID, unitDefID, newTeam)
	end
end
