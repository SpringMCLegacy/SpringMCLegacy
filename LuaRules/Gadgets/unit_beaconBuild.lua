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
local TURRETCONTROL_ID = UnitDefNames["outpost_turretcontrol"].id
local BEACON_POINT_ID = UnitDefNames["beacon_point"].id
local DROPZONE_IDS = {}
GG.DROPZONE_IDS = DROPZONE_IDS

--local MIN_BUILD_RANGE = tonumber(UnitDefNames["beacon"].customParams.minbuildrange) or 230
local MAX_BUILD_RANGE = UnitDefs[TURRETCONTROL_ID].buildDistance
local RADIUS = 230

local DROPSHIP_DELAY = 10 * 30 -- 10s

-- Variables
local towerDefIDs = {} -- towerDefIDs[unitDefID] = "turret" or "energy" or "missile"
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, ...}
local towerOwners = {} -- towerOwners[towerID] = beaconID

local outpostDefs = {} -- outpostDefs[unitDefID] = {cmdDesc = {cmdDescTable}, cost = cost}
GG.outpostDefs = outpostDefs -- TODO: check why this is in GG
local dropZoneDefs = {}

local outpostCMDs = {} -- outpostCMDs[cmdID] = unitDefID
local outpostPointIDs = {} -- outpostPointIDs[outpostID] = outpostPointID
local outpostIDs = {} -- outpostIDs[beaconID] = outpostID

local outpostPointBeaconIDs = {} -- outpostPointBeaconIDs[outpostPointID] = beaconID
local beaconOutpostPointIDs = {} -- beaconOutpostPointIDs[beaconID] = {outpostPointID1, outpostPointID2, outpostPointID3}
GG.beaconOutpostPointIDs = beaconOutpostPointIDs -- for AI

local dropZoneIDs = {} -- dropZoneIDs[teamID] = dropZoneID
local dropZoneBeaconIDs = {} -- dropZoneBeaconIDs[teamID] = beaconID
GG.dropZoneBeaconIDs = dropZoneBeaconIDs
local dropZoneCmdDesc

local activeDropships = {} -- activeDropships[dropshipID] = beaconID
local beaconActive = {} -- beaconActive[beaconID] = dropshipID
local beaconDropshipQueue = {} -- beaconDropshipQueue[beaconID] = {info1 = {}, info2 = {}, ...}

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

local BEACON_POINT_DIST = 400
local function BeaconPoints(beaconID, teamID, x, y, z)
	beaconOutpostPointIDs[beaconID] = {}
	for i = 0, 2 do
		local angle = i * 2 * math.pi / 3
		local dx, dz = math.sin(angle) * BEACON_POINT_DIST, math.cos(angle) * BEACON_POINT_DIST
		local outpostPointID = CreateUnit(BEACON_POINT_ID, x + dx, y, z + dz, "s", teamID)
		Spring.SetUnitAlwaysVisible(outpostPointID, true)
		Spring.SetUnitBlocking(outpostPointID, false, false, false) -- blocking, solid objects, projectiles
		outpostPointBeaconIDs[outpostPointID] = beaconID
		beaconOutpostPointIDs[beaconID][i+1] = outpostPointID
	end
end
GG.BeaconPoints = BeaconPoints

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp and cp.baseclass == "tower" and not name:find("garrison") then -- automatically build table of towers
			towerDefIDs[unitDefID] = cp.turrettype or "turret"
		elseif name:find("dropzone") then -- check for dropzones first
			DROPZONE_IDS[unitDefID] = true
		elseif cp.baseclass == "outpost" then -- automatically build beacon outpost cmdDescs
			local cBillCost = unitDef.metalCost
			local outpostCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_" .. name:upper(), cBillCost),
				type   = CMDTYPE.ICON,
				name   = unitDef.humanName:gsub(" ", "  \n"),
				action = 'outpost',
				tooltip = unitDef.tooltip .. " (C-Bills cost: " .. cBillCost .. ")",
			}
			outpostDefs[unitDefID] = {cmdDesc = outpostCmdDesc, cost = cBillCost}
			outpostCMDs[outpostCmdDesc.id] = unitDefID
		end
	end
	GG.DROPZONE_IDS = DROPZONE_IDS
	dropZoneCmdDesc = {
		id     = GG.CustomCommands.GetCmdID("CMD_DROPZONE", 0), -- dropzone is free
		type   = CMDTYPE.ICON,
		name   = "Dropzone",
		action = 'dropzone',
		tooltip = "Set as primary dropzone",
	}
	for dropZoneDefID in pairs(DROPZONE_IDS) do
		dropZoneDefs[dropZoneDefID] = {cmdDesc = dropZoneCmdDesc, cost = 0}
	end
end

-- REGULAR OUTPOSTS

local function AddOutpostOptions(unitID)
	if not Spring.ValidUnitID(unitID) then return end
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		InsertUnitCmdDesc(unitID, outpostInfo.cmdDesc)
	end
end

local function ToggleOutpostOptions(unitID, on)
	if not Spring.ValidUnitID(unitID) then return end
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, outpostInfo.cmdDesc.id), {disabled = not on})
	end
	--EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, dropZoneCmdDesc.id), {disabled = not on}) -- REMOVE
end
GG.ToggleOutpostOptions = ToggleOutpostOptions

function SpawnCargo(beaconID, targetID, dropshipID, unitDefID, teamID)
	local tx, ty, tz = GetUnitPosition(dropshipID)
	local cargoID = CreateUnit(unitDefID, tx, ty, tz, "s", teamID)
	env = Spring.UnitScript.GetScriptEnv(dropshipID)
	Spring.UnitScript.CallAsUnit(dropshipID, env.LoadCargo, cargoID, targetID, beaconID)
	-- extra behaviour to link outposts with beacons
	if outpostDefs[unitDefID] then
		outpostPointIDs[cargoID] = targetID 
		outpostIDs[targetID] = cargoID
		-- Let unsynced know about this pairing
		Spring.SetUnitRulesParam(cargoID, "beaconID", beaconID)
		Spring.SetUnitRulesParam(targetID, "outpostID", cargoID)
	end
end

function SpawnDropship(beaconID, unitID, teamID, dropshipType, cargo, cost)
	--Spring.Echo("Spawn a dropship!", beaconID, unitID, teamID, dropshipType, cargo, cost)
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) and not outpostIDs[unitID] and Spring.GetUnitTeam(unitID) == teamID then
		local tx,ty,tz = GetUnitPosition(unitID)
		local dropshipID = CreateUnit(dropshipType, tx, ty, tz, "s", teamID)
		--SendToUnsynced("VEHICLE_UNLOADED", dropshipID, teamID)
		if type(cargo) == "table" then
			for i, order in ipairs(cargo) do -- preserve order here
				for orderDefID, count in pairs(order) do
					for i = 1, count do
						DelayCall(SpawnCargo, {beaconID, unitID, dropshipID, orderDefID, teamID}, 1)
					end
				end
			end
		else
			DelayCall(SpawnCargo, {beaconID, unitID, dropshipID, cargo, teamID}, 1)
		end
		return dropshipID
	elseif teamID and not select(3, Spring.GetTeamInfo(teamID)) then -- dropzone moved or beacon was capped, but team lives
		-- Refund
		Spring.SendMessageToTeam(teamID, "No dropzone, order refunded: " .. cost)
		Spring.AddTeamResource(teamID, "metal", cost)
		-- Delete the entire drop queue
		beaconDropshipQueue[beaconID] = {}
	end
end

function NextDropshipQueueItem(beaconID, teamID)
	if beaconID and #beaconDropshipQueue[beaconID] > 0 then
		local item = beaconDropshipQueue[beaconID][1]
		if item.sound then
			GG.PlaySoundForTeam(teamID, item.sound, 1)
		end
		local dropshipID = SpawnDropship(beaconID, item.target, teamID, item.dropshipType, item.cargo, item.cost)
		if dropshipID then -- can fail if beacon was lost or dropzone moved TODO: so reset queue here?
			beaconActive[beaconID] = dropshipID
			activeDropships[dropshipID] = beaconID
		end
	end
end

function EnqueueDropship(beaconID, beaconPointID, teamID, info, priority)
	if not beaconDropshipQueue[beaconID] then beaconDropshipQueue[beaconID] = {} end -- TODO: move to unitcreated?
	if priority then -- go to the top of the list, or just after currently active drop
		table.insert(beaconDropshipQueue[beaconID], beaconActive[beaconID] and 2 or 1, info)
	else -- add to the end of the list
		table.insert(beaconDropshipQueue[beaconID], info)
	end
	Spring.SendMessageToTeam(teamID, "Adding dropship " .. info.dropshipType .. " to beacon " .. beaconID .. " (queue length " .. (#beaconDropshipQueue[beaconID]) .. ")")
	-- If it's the first item in queue, start emptying
	if #beaconDropshipQueue[beaconID] == 1 then
		NextDropshipQueueItem(beaconID, teamID)
	end
end

function DropzoneFree(beaconID, teamID)
	--Spring.Echo("DropzoneFree", beaconID, teamID)
	if beaconID then
		beaconActive[beaconID] = false
		table.remove(beaconDropshipQueue[beaconID], 1)
		NextDropshipQueueItem(beaconID, teamID)
	else
		Spring.Echo("Uhoh, FLOZi logic fail. DropzoneFree was called with a nil beaconID. Team was", teamID)
	end
end
GG.DropzoneFree = DropzoneFree

function DropshipBugOut(beaconID, teamID, outpostID)
	if beaconID then
		local dropshipID = beaconActive[beaconID]
		local bugOut = false
		if dropshipID then -- there is a dropship in game
			-- first check if this dropship is trying to land at a given point or the main beacon
			if outpostID then
				-- check if the currently active dropship is trying to land at that point
				local item = beaconDropshipQueue[beaconID][1]
				if item.target == outpostID then
					bugOut = true
				end
			else -- assume main beacon was lost, all dropships must abort
				bugOut = true
			end
			if bugOut then
				env = Spring.UnitScript.GetScriptEnv(dropshipID)
				if env and env.BugOut then
					--Spring.UnitScript.CallAsUnit(dropshipID, env.BugOut)
				end
				DropzoneFree(beaconID, teamID) -- mark the zone as free and continue with the queue
			end
		end
	else
		Spring.Echo("Uhoh, FLOZi logic fail. DropshipBugOut was called with a nil beaconID. Team was", teamID)
	end
end	

function DropshipDelivery(beaconID, beaconPointID, teamID, dropshipType, cargo, cost, sound, delay)
	local info = {
		["target"] = beaconPointID, 
		["dropshipType"] = dropshipType, 
		["cargo"] = cargo, 
		["cost"] = cost, 
		["sound"] = sound
	}
	-- check dropshipType for mech deliveries and add to front of queue
	local priority = delay == 0
	DelayCall(EnqueueDropship, {beaconID, beaconPointID, teamID, info, priority}, delay)
	if cost then -- deduct cost immediately to give feedback to player that order was accepted
	-- will be refunded later if it fails (e.g. beacon capped)
		--Spring.Echo("COST!?", cost)
		UseTeamResource(teamID, "metal", cost)
	end
end
GG.DropshipDelivery = DropshipDelivery

-- DROPZONE
local function SetDropZone(beaconID, teamID)
	local currDropZone = dropZoneIDs[teamID]
	if currDropZone then
		--ToggleOutpostOptions(dropZoneBeaconIDs[teamID], true) -- REMOVE
		DestroyUnit(currDropZone, false, true)
		GG.DropshipLeft(teamID, true) -- reset the timer
	end
	local x,y,z = GetUnitPosition(beaconID)
	local side = GG.teamSide[teamID]
	local dropZoneID = CreateUnit(side .. "_dropzone", x,y,z, "s", teamID)
	dropZoneIDs[teamID] = dropZoneID
	dropZoneBeaconIDs[teamID] = beaconID
	Spring.SetUnitRulesParam(beaconID, "secure", 1)
end

-- TOWERS
function LimitTowerType(unitID, teamID, towerType, increase)	
	local towersRemaining = buildLimits[unitID][towerType]
	if increase then
		buildLimits[unitID][towerType] = towersRemaining + increase
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
GG.LimitTowerType = LimitTowerType -- for outpost_turretcontrol perk

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	hotSwapIDs[unitID] = nil
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == BEACON_ID then
		InsertUnitCmdDesc(unitID, dropZoneCmdDesc)
	elseif unitDefID == BEACON_POINT_ID then
		AddOutpostOptions(unitID)
	elseif unitDefID == TURRETCONTROL_ID then
		buildLimits[unitID] = {["turret"] = 2, ["energy"] = 1, ["missile"] = 1}
		LimitTowerType(unitID, teamID, "energy") -- reduce to 0 so we get the BP greyed out
		LimitTowerType(unitID, teamID, "missile") -- reduce to 0 so we get the BP greyed out
	elseif cp and cp.baseclass == "tower" then
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			towerOwners[unitID] = builderID
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	local towerOwnerID = towerOwners[unitID]
	if towerOwnerID then -- unit was a turret with owning beacon, open the slot back up
		local towerType = towerDefIDs[unitDefID]
		LimitTowerType(towerOwnerID, teamID, towerType, 1) -- increase limit
		towerOwners[unitID] = nil
	end
	if DROPZONE_IDS[unitDefID] then -- unit was a team's dropzone, reset outpost options
		--ToggleOutpostOptions(dropZoneBeaconIDs[teamID], true) -- REMOVE
		dropZoneIDs[teamID] = nil
		dropZoneBeaconIDs[teamID] = nil
	elseif outpostDefs[unitDefID] then
		local outpostPointID = outpostPointIDs[unitID]
		if outpostPointID then -- beaconID can be nil if /give testing
			GG.Delay.DelayCall(SetUnitRulesParam, {unitID, "beaconID", ""}, 5) -- delay for safety
			env = Spring.UnitScript.GetScriptEnv(outpostPointID)
			if env and env.ChangeType then
				Spring.UnitScript.CallAsUnit(outpostPointID, env.ChangeType, false)
			end
			outpostPointIDs[unitID] = nil
			outpostIDs[outpostPointID] = nil
			-- Re-add outpost options to beacon
			ToggleOutpostOptions(outpostPointID, true)
			DropshipBugOut(outpostPointBeaconIDs[outpostPointID], teamID, unitID) -- /give testing won't bug out
		end
	elseif activeDropships[unitID] then
		--Spring.Echo("Oh noes, my dropship! Send the next one", attackerID, attackerDefID, attackerTeam)
		DropzoneFree(activeDropships[unitID], teamID)
		activeDropships[unitID] = nil
	end
end


local lastDamaged = {} -- lastDamaged[unitID] = lastDamagedFrame
local MIN_LAST_DAMAGED = 20 * 30 -- 20s
function gadget:UnitDamaged(unitID, unitDefID, teamID, damage)
	local cp = UnitDefs[unitDefID].customParams
	if cp.baseclass == "outpost" then -- unit is an outpost 
		local lastDamagedFrame = lastDamaged[unitID] or 0
		local currFrame = GetGameFrame()
		local name = UnitDefs[unitDefID].name
		if lastDamagedFrame < currFrame - MIN_LAST_DAMAGED then
			lastDamaged[unitID] = currFrame
			GG.PlaySoundForTeam(teamID, "BB_" .. name .. "_UnderAttack", 1)
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == BEACON_ID then
		for i, outpostPointID in pairs(beaconOutpostPointIDs[unitID]) do			
			DelayCall(TransferUnit, {outpostPointID, newTeam}, 1)
			--DelayCall(SetUnitNeutral,{outpostPoint, newTeam == GAIA_TEAM_ID}, 2) -- REMOVE
		end
		if dropZoneBeaconIDs[oldTeam] == unitID and oldTeam ~= GAIA_TEAM_ID then
			local dropZoneID = dropZoneIDs[oldTeam]
			DelayCall(Spring.DestroyUnit, {dropZoneID, false, true}, 1)
			if newTeam == GAIA_TEAM_ID then -- dropzone given on team death, 
				-- will be destroyed next frame but needs beaconID in UnitDestroyed
				dropZoneBeaconIDs[newTeam] = unitID
			end
		end
		DropshipBugOut(unitID, teamID)
	elseif unitDefID == TURRETCONTROL_ID then
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
		if cmdID == dropZoneCmdDesc.id then
			if Spring.GetUnitRulesParam(unitID, "secure") == 0 then 
				Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Under attack!")
				return false 
			elseif GG.dropShipStatus[teamID] == 1 then
				-- double check if dropship is not in action
				if Spring.GetTeamUnitDefCount(teamID, GG.teamDropShipTypes[teamID].def) ~= 0 then 
					Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Dropship is active!")
					return false
				end
				-- TODO: this will allow the command otherwise which is also dangerous, as dropship can be 'ACTIVE' without being in play
				-- TODO: Solution is probably to make a new dropship state and have ACTIVE only the case when it is on map
			elseif GG.orderStatus[teamID] > 0 and GG.teamDropZones[teamID] then
				Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Order pending!")
				return false 
			end
			SetDropZone(unitID, teamID)
		end
	elseif unitDefID == BEACON_POINT_ID then
		if outpostCMDs[cmdID] and not outpostIDs[unitID] then
			if Spring.GetUnitRulesParam(unitID, "secure") == 0 then 
				Spring.SendMessageToTeam(teamID, "Cannot place outpost at beacon - Under attack!")
				return false 
			end
			local outpostDefID = outpostCMDs[cmdID]
			local cost = outpostDefs[outpostDefID] and outpostDefs[outpostDefID].cost or 1000
			if cost <= GetTeamResources(teamID, "metal") then
				--Spring.Echo("I'm totally gonna outpost your beacon bro!")
				ToggleOutpostOptions(unitID, false)
				DropshipDelivery(outpostPointBeaconIDs[unitID], unitID, teamID, "is_avenger", outpostDefID, cost, "BB_Dropship_Inbound", DROPSHIP_DELAY)
			else
				GG.PlaySoundForTeam(teamID, "BB_Insufficient_Funds", 1)
			end
		elseif cmdID == CMD.SELFD then -- Disallow self-d
			return false
		end	
	elseif unitDefID == TURRETCONTROL_ID then
		if cmdID < 0 then
			local towerType = towerDefIDs[-cmdID]
			if not towerType then return false end
			if unitDefID == TURRETCONTROL_ID then -- TurretControl has limited build radius -- TODO: within the beacon
				local tx, ty, tz = unpack(cmdParams)
				local dist = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
				--[[if dist < MIN_BUILD_RANGE then
					Spring.SendMessageToTeam(teamID, "Too close to beacon")
					return false
				else]]
				if dist > MAX_BUILD_RANGE then
					Spring.SendMessageToTeam(teamID, "Too far from Turret Control!")
					return false
				end
			end
			return LimitTowerType(unitID, teamID, towerType)
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
--[[
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
	local cp = unitDef.customParams
	if cp and cp.baseclass == "outpost" then
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
end]]

end
