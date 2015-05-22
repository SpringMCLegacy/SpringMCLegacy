function gadget:GetInfo()
	return {
		name		= "Beacon Construction",
		desc		= "Controls beacons' construction abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/13",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetTeamResources		= Spring.GetTeamResources
local GetUnitPosition		= Spring.GetUnitPosition
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitNeutral		= Spring.SetUnitNeutral
local SetUnitRotation		= Spring.SetUnitRotation
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local UPLINK_ID = UnitDefNames["upgrade_uplink"].id
local IS_DROPZONE_ID = UnitDefNames["is_dropzone"].id
local CL_DROPZONE_ID = UnitDefNames["cl_dropzone"].id -- FIXME: ugly
local DROPZONE_IDS = {[IS_DROPZONE_ID] = true, [CL_DROPZONE_ID] = true}
local WALL_ID = UnitDefNames["wall"].id
local GATE_ID = UnitDefNames["wall_gate"].id
local MIN_BUILD_RANGE = tonumber(UnitDefNames["beacon"].customParams.minbuildrange) or 230
local MAX_BUILD_RANGE = UnitDefNames["beacon"].buildDistance
local RADIUS = 230
local NUM_SEGMENTS = 12
local DROPSHIP_DELAY = 10 * 30 -- 10s
local WALL_COST = UnitDefs[WALL_ID].metalCost * NUM_SEGMENTS -- FIXME: ugly!

local CMD_GATE = GG.CustomCommands.GetCmdID("CMD_GATE")
local CMD_UPGRADE = GG.CustomCommands.GetCmdID("CMD_UPGRADE")

-- Variables
local towerDefIDs = {} -- towerDefIDs[unitDefID] = "turret" or "sensor"
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, sensor = 1}
local towerOwners = {} -- towerOwners[towerID] = beaconID

local outpostDefs = {} -- outpostDefs[unitDefID] = {cmdDesc = {cmdDescTable}, cost = cost}
local upgradeIDs = {} -- upgradeIDs[cmdID] = unitDefID
local beaconIDs = {} -- beaconIDs[outpostID] = beaconID
local outpostIDs = {} -- outpostIDs[beaconID] = outpostID
local dropZoneIDs = {} -- dropZoneIDs[teamID] = dropZoneID
local dropZoneBeaconIDs = {} -- dropZoneBeaconIDs[teamID] = beaconID
local dropZoneCmdDesc

local wallIDs = {} -- wallIDs[beaconID] = {wall1, wall2 ... wall12}
local wallInfos = {} -- wallInfos[wallID] = {beaconID = beaconID, angle = angle, px = px, pz = pz}
local beaconGateIDs = {} -- beaconGateIDs[beaconID] = gateID
local wallCmdDesc
local gateCmdDesc
local wallRepairCmdDesc

local hotSwapIDs = {} -- hotSwapIDs[unitID] = true
local function HotSwap(unitID, unitDefID, teamID)
	hotSwapIDs[unitID] = true
	local x,y,z = Spring.GetUnitPosition(unitID)
	if not Spring.GetUnitIsDead(unitID) then
		Spring.DestroyUnit(unitID, false, true)
		--Spring.Echo("Destroy:", unitID)
	end
	if not teamID then
		teamID = Spring.GetUnitTeam(unitID)
	end
	DelayCall(Spring.CreateUnit,{unitDefID, x,y,z, "s", teamID, false, false, unitID, nil}, 3) -- 3 frame delay appears to be minimum
end

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp and cp.towertype then -- automatically build table of towers
			towerDefIDs[unitDefID] = cp.towertype
		elseif name:find("upgrade") then -- automatically build beacon upgrade cmdDescs
			local cBillCost = unitDef.metalCost
			local upgradeCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_UPGRADE_" .. name, cBillCost),
				type   = CMDTYPE.ICON,
				name   = unitDef.humanName:gsub(" ", "  \n"),
				action = 'upgrade',
				tooltip = "C-Bill cost: " .. cBillCost,
			}
			outpostDefs[unitDefID] = {cmdDesc = upgradeCmdDesc, cost = cBillCost}
			upgradeIDs[upgradeCmdDesc.id] = unitDefID
		elseif unitDefID == WALL_ID then -- handle walls separately
			local cBillCost = unitDef.metalCost * NUM_SEGMENTS
			wallCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_UPGRADE_" .. name, cBillCost),
				type   = CMDTYPE.ICON,
				name   = "Defensive\nWalls",
				action = 'upgrade',
				tooltip = "C-Bill cost: " .. cBillCost,
			}
			upgradeIDs[wallCmdDesc.id] = unitDefID
			wallRepairCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_WALLREPAIR", cBillCost * 0.5),
				type   = CMDTYPE.ICON,
				name   = "Repair\n Walls",
				action = 'upgrade',
				tooltip = "C-Bill cost: " .. cBillCost * 0.5,
			}
		elseif unitDefID == GATE_ID then -- and gates too
			local cBillCost = unitDef.metalCost
			gateCmdDesc = {
				id     = CMD_GATE,
				type   = CMDTYPE.ICON,
				name   = "Install\n Gate",
				action = 'upgrade',
				tooltip = "C-Bill cost: " .. cBillCost,
			}
		end
	end
	dropZoneCmdDesc = {
		id     = GG.CustomCommands.GetCmdID("CMD_DROPZONE", 0), -- dropzone is free
		type   = CMDTYPE.ICON,
		name   = "Dropzone",
		action = 'dropzone',
		tooltip = "Set as primary dropzone",
	}
	outpostDefs[IS_DROPZONE_ID] = {cmdDesc = dropZoneCmdDesc, cost = 0}
	outpostDefs[CL_DROPZONE_ID] = {cmdDesc = dropZoneCmdDesc, cost = 0}
end

-- REGULAR UPGRADES
local function AddUpgradeOptions(unitID)
	if not Spring.ValidUnitID(unitID) then return end
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		InsertUnitCmdDesc(unitID, outpostInfo.cmdDesc)
	end
	InsertUnitCmdDesc(unitID, dropZoneCmdDesc)
end

local function RemoveUpgradeOptions(unitID)
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, outpostInfo.cmdDesc.id))
	end
	RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, dropZoneCmdDesc.id))
end

function SpawnCargo(beaconID, dropshipID, unitDefID, teamID)
	env = Spring.UnitScript.GetScriptEnv(dropshipID)
	local tx, ty, tz = GetUnitPosition(dropshipID)
	local cargoID = CreateUnit(unitDefID, tx, ty, tz, "s", teamID)
	env = Spring.UnitScript.GetScriptEnv(dropshipID)
	Spring.UnitScript.CallAsUnit(dropshipID, env.LoadCargo, cargoID, beaconID)
	-- extra behaviour to link outposts with beacons
	if outpostDefs[unitDefID] then
		beaconIDs[cargoID] = beaconID 
		outpostIDs[beaconID] = cargoID
		-- Let unsynced know about this pairing
		Spring.SetUnitRulesParam(cargoID, "beaconID", beaconID)
	end
end

function SpawnDropship(unitID, teamID, dropshipType, cargo, cost)
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) and not outpostIDs[unitID] and Spring.GetUnitTeam(unitID) == teamID then
		local tx,ty,tz = GetUnitPosition(unitID)
		local dropshipID = CreateUnit(dropshipType, tx, ty, tz, "s", teamID)
		--SendToUnsynced("VEHICLE_UNLOADED", dropshipID, teamID)
		if type(cargo) == "table" then
			for i, order in ipairs(cargo) do -- preserve order here
				for orderDefID, count in pairs(order) do
					for i = 1, count do
						DelayCall(SpawnCargo, {unitID, dropshipID, orderDefID, teamID}, 1)
					end
				end
			end
		else
			DelayCall(SpawnCargo, {unitID, dropshipID, cargo, teamID}, 1)
		end
	else -- dropzone moved or beacon was capped
		-- Refund
		Spring.AddTeamResource(teamID, "metal", cost)
	end
end

function DropshipDelivery(unitID, teamID, dropshipType, cargo, cost, sound, delay)
	UseTeamResource(teamID, "metal", cost)
	if sound then
		GG.PlaySoundForTeam(teamID, sound, 1)
	end
	DelayCall(SpawnDropship, {unitID, teamID, dropshipType, cargo, cost}, delay)
end
GG.DropshipDelivery = DropshipDelivery

-- DROPZONE
local function SetDropZone(beaconID, teamID)
	local currDropZone = dropZoneIDs[teamID]
	if currDropZone then
		AddUpgradeOptions(dropZoneBeaconIDs[teamID])
		DestroyUnit(currDropZone, false, true)
	end
	local x,y,z = GetUnitPosition(beaconID)
	local side = select(5, Spring.GetTeamInfo(teamID))
	if side:find("inner") then side = "IS"
	elseif side:find("clan") then side = "CL"
	elseif side == "" then side = (teamID == 0 and "IS") or "CL" end -- ugly hack for spring.exe blank sides
	local dropZoneID = CreateUnit(side .. "_dropzone", x,y,z, "s", teamID)
	dropZoneIDs[teamID] = dropZoneID
	dropZoneBeaconIDs[teamID] = beaconID
end

-- WALLS & GATES
local function BuildWalls(beaconID, teamID)
	UseTeamResource(teamID, "metal", WALL_COST)
	wallIDs[beaconID] = {}
	local x,_,z = GetUnitPosition(beaconID)
	for i = 0, NUM_SEGMENTS - 1 do
		local angle = math.rad(i * (360 / NUM_SEGMENTS))
		local px = x + math.sin(angle) * RADIUS
		local pz = z + math.cos(angle) * RADIUS
		local wallID = CreateUnit("wall", px, 0, pz, "s", teamID)
		InsertUnitCmdDesc(wallID, gateCmdDesc)
		SetUnitNeutral(wallID, true)
		SetUnitRotation(wallID, 0, -angle, 0)
		wallIDs[beaconID][i+1] = wallID
		wallInfos[wallID] = {beaconID = beaconID, angle = angle, px = px, pz = pz}
	end
	GG.PlaySoundForTeam(teamID, "BB_wall_deployed", 1)
end

local function BuildGate(wallID, teamID)
	HotSwap(wallID, "wall_gate", teamID)
	--[[local x,y,z = GetUnitPosition(wallID)
	DestroyUnit(wallID)
	local gateID = CreateUnit("wall_gate", x,y,z, "s", teamID)
	SetUnitRotation(gateID, 0, -wallInfos[wallID].angle, 0)
	SetUnitNeutral(gateID, true)]]
	DelayCall(SetUnitRotation, {wallID, 0, -wallInfos[wallID].angle, 0}, 3)
	DelayCall(SetUnitNeutral, {wallID, true}, 3)
	beaconGateIDs[wallInfos[wallID].beaconID] = wallID
end

local function RepairWalls(beaconID, teamID)
	UseTeamResource(teamID, "metal", UnitDefs[WALL_ID].metalCost * NUM_SEGMENTS * 0.5) -- FIXME: ugly!
	for i, wallID in pairs(wallIDs[beaconID]) do
		local unitDefID = Spring.GetUnitDefID(wallID)
		if not Spring.GetUnitIsDead(wallID) and (unitDefID == WALL_ID or unitDefID == GATE_ID) then
			Spring.SetUnitHealth(wallID, UnitDefs[WALL_ID].health)
			local wallRepairCmdPos = FindUnitCmdDesc(wallID, wallRepairCmdDesc.id)
			if wallRepairCmdPos then
				RemoveUnitCmdDesc(wallID, wallRepairCmdPos)
			end
		else -- unit needs replacing
			local info = wallInfos[wallID]
			local newWallID = CreateUnit("wall", info.px, 0, info.pz, "s", teamID) -- can't rely on creating with old ID here incase it was reused
			SetUnitNeutral(newWallID, true)
			SetUnitRotation(newWallID, 0, -info.angle, 0)
			-- sub the new ID back into everything in place of old ID
			wallInfos[newWallID] = {beaconID = beaconID, angle = info.angle, px = info.px, pz = info.pz}
			wallInfos[wallID] = nil
			wallIDs[beaconID][i] = newWallID
			if not beaconGateIDs[beaconID] then
				InsertUnitCmdDesc(newWallID, gateCmdDesc)
			end
		end	
	end
end

-- TOWERS
function LimitTowerType(unitID, teamID, towerType, increase)	
	local towersRemaining = buildLimits[unitID][towerType]
	if increase then
		buildLimits[unitID][towerType] = towersRemaining + 1
		for tDefID, tType in pairs(towerDefIDs) do
			if tType == towerType then
				local cmdDescID = FindUnitCmdDesc(unitID, -tDefID)
				if cmdDescID then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = {}})
				end
			end
		end
	elseif towersRemaining == 0 then 
		Spring.SendMessageToTeam(teamID, "Limit reached for " .. towerType)
		return false 
	else
		buildLimits[unitID][towerType] = towersRemaining - 1
		if towersRemaining == 1 then
			for tDefID, tType in pairs(towerDefIDs) do
				if tType == towerType then
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, -tDefID), {disabled = true, params = {"L"}})
				end
			end
		end
		return true
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	hotSwapIDs[unitID] = nil
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == BEACON_ID then
		AddUpgradeOptions(unitID)
		--InsertUnitCmdDesc(unitID, wallCmdDesc)
	elseif unitDefID == UPLINK_ID then
		buildLimits[unitID] = {["turret"] = 4, ["sensor"] = 1}
	elseif cp and cp.towertype then
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			towerOwners[unitID] = builderID
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	local towerOwnerID = towerOwners[unitID]
	if towerOwnerID then -- unit was a turret with owning beacon, open the slot back up
		local towerType = towerDefIDs[unitDefID]
		LimitTowerType(towerOwnerID, teamID, towerType, true) -- increase limit
		towerOwners[unitID] = nil
	end
	if unitDefID == IS_DROPZONE_ID or unitDefID == CL_DROPZONE_ID then -- unit was a team's dropzone, reset upgrade options
		AddUpgradeOptions(dropZoneBeaconIDs[teamID])
		dropZoneIDs[teamID] = nil
		dropZoneBeaconIDs[teamID] = nil
	elseif outpostDefs[unitDefID] then
		local beaconID = beaconIDs[unitID]
		if beaconID then -- baconID can be nil if /give testing
			SetUnitRulesParam(unitID, "beaconID", "")
			env = Spring.UnitScript.GetScriptEnv(beaconID)
			Spring.UnitScript.CallAsUnit(beaconID, env.ChangeType, false)
			beaconIDs[unitID] = nil
			outpostIDs[beaconID] = nil
			-- Re-add upgrade options to beacon
			AddUpgradeOptions(beaconID)
		end
	end
	local wallInfo = wallInfos[unitID]
	if wallInfo and not hotSwapIDs[unitID] then -- unit was a wall or gate piece, not being hotswapped
		for _, wallID in pairs(wallIDs[wallInfo.beaconID]) do
			local wallRepairCmdPos = FindUnitCmdDesc(wallID, wallRepairCmdDesc.id)
			if not wallRepairCmdPos then
				InsertUnitCmdDesc(wallID, wallRepairCmdDesc)
			end
		end
		if unitDefID == GATE_ID then
			beaconGateIDs[wallInfo.beaconID] = nil
			for _, wallID in pairs(wallIDs[wallInfo.beaconID]) do
				InsertUnitCmdDesc(wallID, gateCmdDesc)
			end
		end
	end
end


local lastDamaged = {} -- lastDamaged[unitID] = lastDamagedFrame
local MIN_LAST_DAMAGED = 20 * 30 -- 20s
function gadget:UnitDamaged(unitID, unitDefID, teamID, damage)
	local name = UnitDefs[unitDefID].name
	if name:find("upgrade") then -- unit is an upgrade 
		local lastDamagedFrame = lastDamaged[unitID] or 0
		local currFrame = GetGameFrame()
		if lastDamagedFrame < currFrame - MIN_LAST_DAMAGED then
			lastDamaged[unitID] = currFrame
			GG.PlaySoundForTeam(teamID, "BB_" .. name .. "_UnderAttack", 1)
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == BEACON_ID then
		for outpostID, beaconID in pairs(beaconIDs) do			
			if beaconID == unitID then
				DelayCall(TransferUnit, {outpostID, newTeam}, 1)
				DelayCall(SetUnitNeutral,{outpostID, newTeam == GAIA_TEAM_ID}, 2)
			end
		end
		local walls = wallIDs[unitID] or {}
		for _, wallID in pairs(walls) do
			DelayCall(TransferUnit, {wallID, newTeam}, 1)
			DelayCall(SetUnitNeutral,{wallID, newTeam == GAIA_TEAM_ID}, 2)
		end
		if dropZoneBeaconIDs[oldTeam] == unitID and oldTeam ~= GAIA_TEAM_ID then
			local dropZoneID = dropZoneIDs[oldTeam]
			Spring.DestroyUnit(dropZoneID, false, true)
			if newTeam == GAIA_TEAM_ID then -- dropzone given on team death, 
				-- will be destroyed next frame but needs beaconID in UnitDestroyed
				dropZoneBeaconIDs[newTeam] = unitID
			end
		end
	elseif unitDefID == UPLINK_ID then
		for towerID, beaconID in pairs(towerOwners) do
			if beaconID == unitID then
				DelayCall(TransferUnit, {towerID, newTeam}, 1)
				local env = Spring.UnitScript.GetScriptEnv(towerID)
				Spring.UnitScript.CallAsUnit(towerID, env.TeamChange, newTeam)
				DelayCall(SetUnitNeutral,{towerID, newTeam == GAIA_TEAM_ID}, 2)
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == BEACON_ID then
		if upgradeIDs[cmdID] then
			local upgradeDefID = upgradeIDs[cmdID]
			local cost = outpostDefs[upgradeDefID] and outpostDefs[upgradeDefID].cost or WALL_COST
			if cost <= GetTeamResources(teamID, "metal") then
				if upgradeDefID == WALL_ID then
					BuildWalls(unitID, teamID)
					RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID))
				else
					--Spring.Echo("I'm totally gonna upgrade your beacon bro!")
					RemoveUpgradeOptions(unitID)
					DropshipDelivery(unitID, teamID, "is_avenger", upgradeDefID, cost, "BB_Dropship_Inbound", DROPSHIP_DELAY)
				end
			else
				GG.PlaySoundForTeam(teamID, "BB_Insufficient_Funds", 1)
			end
		elseif cmdID == dropZoneCmdDesc.id then
			RemoveUpgradeOptions(unitID)
			SetDropZone(unitID, teamID)
		elseif cmdID == CMD.SELFD then -- Disallow self-d
			return false
		end
	elseif unitDefID == UPLINK_ID then
		if cmdID < 0 then
			local towerType = towerDefIDs[-cmdID]
			if not towerType then return false end
			--[[local tx, ty, tz = unpack(cmdParams)
			local dist = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
			if dist < MIN_BUILD_RANGE then
				Spring.SendMessageToTeam(teamID, "Too close to beacon")
				return false
			elseif dist > MAX_BUILD_RANGE then
				Spring.SendMessageToTeam(teamID, "Too far from beacon")
				return false
			end]]
			return LimitTowerType(unitID, teamID, towerType)
		end
	elseif unitDefID == WALL_ID or unitDefID == GATE_ID then
		if unitDefID == WALL_ID and cmdID == CMD_GATE then
			local beaconID = wallInfos[unitID].beaconID
			if beaconGateIDs[beaconID] then return false end -- gate already exists
			BuildGate(unitID, teamID)
			-- Disable gates for all other wall segments in the ring
			for _, wallID in ipairs(wallIDs[beaconID]) do
				RemoveUnitCmdDesc(wallID, FindUnitCmdDesc(wallID, cmdID))
			end
		elseif cmdID == wallRepairCmdDesc.id then
			local _, cost = GG.CustomCommands.GetCmdID("CMD_WALLREPAIR")
			if cost <= GetTeamResources(teamID, "metal") then
				local beaconID = wallInfos[unitID].beaconID
				RepairWalls(beaconID, teamID)
			else 
				return false 
			end
		end
	elseif UnitDefs[unitDefID].customParams.decal then
		return false -- disallow all commands to decals
	end
	return true
end

function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		if DROPZONE_IDS[unitDefID] then
			Spring.DestroyUnit(unitID, false, true)
		else
			gadget:UnitCreated(unitID, unitDefID, teamID)
		end
	end
end

else
--	UNSYNCED

-- localisations
local GetUnitRulesParam			= Spring.GetUnitRulesParam
-- SyncedRead
local GetGameFrame				= Spring.GetGameFrame
-- UnsyncedRead
local GetSelectedUnitsSorted	= Spring.GetSelectedUnitsSorted
-- UnsyncedCtrl
local SelectUnitArray			= Spring.SelectUnitArray
-- variables
local outpostDefIDs = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	if unitDef.name:find("upgrade") then
		outpostDefIDs[unitDefID] = true
	end
end
local lastFrame = 0

function gadget:Update()
	local frameNum = Spring.GetGameFrame()
	if lastFrame == frameNum then
		return --same frame
	end
	lastFrame = frameNum
	--Spring.Echo("unsynced gameframe: " .. lastFrame)
	local selected = GetSelectedUnitsSorted()
	for unitDefID, units in pairs(selected) do
		if outpostDefIDs[unitDefID] then
			for _, unitID in pairs(units) do
				SelectUnitArray({GetUnitRulesParam(unitID, "beaconID")}, true)
			end
		end
	end
end

end
