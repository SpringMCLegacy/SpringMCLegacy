function gadget:GetInfo()
	return {
		name		= "Game - Dropships",
		desc		= "Controls dropship spawning",
		author		= "FLOZi (C. Lawrence)",
		date		= "27/07/20",
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
local GetUnitPosition		= Spring.GetUnitPosition
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local BEACON_ID = UnitDefNames["beacon"].id
local DROPZONE_IDS = {}
GG.DROPZONE_IDS = DROPZONE_IDS

local DROPSHIP_DELAY = 10 * 30 -- 10s

-- Variables
local dropZoneDefs = {}

local dropZoneIDs = {} -- dropZoneIDs[teamID] = dropZoneID
local dropZoneBeaconIDs = {} -- dropZoneBeaconIDs[teamID] = beaconID
GG.dropZoneBeaconIDs = dropZoneBeaconIDs
local dropZoneCmdDesc

local activeDropships = {} -- activeDropships[dropshipID] = beaconID
local beaconActive = {} -- beaconActive[beaconID] = dropshipID
local beaconDropshipQueue = {} -- beaconDropshipQueue[beaconID] = {info1 = {}, info2 = {}, ...}


function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if name:find("dropzone") then -- check for dropzones first
			DROPZONE_IDS[unitDefID] = true
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

function SpawnCargo(beaconID, targetID, dropshipID, unitDefID, teamID)
	local tx, ty, tz = GetUnitPosition(dropshipID)
	local cargoID = CreateUnit(unitDefID, tx, ty, tz, "s", teamID)
	env = Spring.UnitScript.GetScriptEnv(dropshipID)
	Spring.UnitScript.CallAsUnit(dropshipID, env.LoadCargo, cargoID, targetID, beaconID)
	-- extra behaviour to link outposts with beacons
	if GG.outpostDefs[unitDefID] then
		GG.AssociateOutpost(beaconID, targetID, cargoID)
	end
end

function SpawnDropship(beaconID, unitID, teamID, dropshipType, cargo, cost)
	--Spring.Echo("Spawn a dropship!", beaconID, unitID, teamID, dropshipType, cargo, cost)
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) --and not outpostIDs[unitID] 
	and Spring.GetUnitTeam(unitID) == teamID then
		local tx,ty,tz = GetUnitPosition(unitID)
		local dropshipID = CreateUnit(dropshipType, tx, ty, tz, "s", teamID)
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
GG.DropshipBugOut = DropshipBugOut

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

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == BEACON_ID then
		InsertUnitCmdDesc(unitID, dropZoneCmdDesc)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if DROPZONE_IDS[unitDefID] then -- unit was a team's dropzone, reset outpost options
		dropZoneIDs[teamID] = nil
		dropZoneBeaconIDs[teamID] = nil
	elseif activeDropships[unitID] then
		--Spring.Echo("Oh noes, my dropship! Send the next one", attackerID, attackerDefID, attackerTeam)
		DropzoneFree(activeDropships[unitID], teamID)
		activeDropships[unitID] = nil
	end
end


function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
	if unitID == dropZoneIDs[oldTeam] then
		return false
	end
	return true
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == BEACON_ID then
		if dropZoneBeaconIDs[oldTeam] == unitID then
			local dropZoneID = dropZoneIDs[oldTeam]
			DelayCall(Spring.DestroyUnit, {dropZoneID, false, true}, 1)
		end
		DropshipBugOut(unitID, oldTeam)
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

end
