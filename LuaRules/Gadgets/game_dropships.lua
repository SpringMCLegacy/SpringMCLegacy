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
local DROPSHIP_DELAY = 10 * 30 -- 10s

-- Variables
local activeDropships = {} -- activeDropships[dropshipID] = beaconID
local beaconActive = {} -- beaconActive[beaconID] = dropshipID
local beaconDropshipQueue = {} -- beaconDropshipQueue[beaconID] = {info1 = {}, info2 = {}, ...}

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

function BeaconNextQueueItem(beaconID, teamID)
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

function BeaconEnqueueDropship(beaconID, beaconPointID, teamID, info, priority)
	if not beaconDropshipQueue[beaconID] then beaconDropshipQueue[beaconID] = {} end -- TODO: move to unitcreated?
	if priority then -- go to the top of the list, or just after currently active drop
		table.insert(beaconDropshipQueue[beaconID], beaconActive[beaconID] and 2 or 1, info)
	else -- add to the end of the list
		table.insert(beaconDropshipQueue[beaconID], info)
	end
	Spring.SendMessageToTeam(teamID, "Adding dropship " .. info.dropshipType .. " to beacon " .. beaconID .. " (queue length " .. (#beaconDropshipQueue[beaconID]) .. ")")
	-- If it's the first item in queue, start emptying
	if #beaconDropshipQueue[beaconID] == 1 then
		BeaconNextQueueItem(beaconID, teamID)
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
	DelayCall(BeaconEnqueueDropship, {beaconID, beaconPointID, teamID, info, priority}, delay)
	if cost then -- deduct cost immediately to give feedback to player that order was accepted
	-- will be refunded later if it fails (e.g. beacon capped)
		--Spring.Echo("COST!?", cost)
		UseTeamResource(teamID, "metal", cost)
	end
end
GG.DropshipDelivery = DropshipDelivery

function BeaconFree(beaconID, teamID)
	--Spring.Echo("BeaconFree", beaconID, teamID)
	if beaconID then
		beaconActive[beaconID] = false
		table.remove(beaconDropshipQueue[beaconID], 1)
		BeaconNextQueueItem(beaconID, teamID)
	else
		Spring.Echo("Uhoh, FLOZi logic fail. BeaconFree was called with a nil beaconID. Team was", teamID)
	end
end

function BeaconDropshipBugOut(beaconID, teamID, outpostID)
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
				BeaconFree(beaconID, teamID) -- mark the zone as free and continue with the queue
			end
		end
	else
		Spring.Echo("Uhoh, FLOZi logic fail. BeaconDropshipBugOut was called with a nil beaconID. Team was", teamID)
	end
end	
GG.BeaconDropshipBugOut = BeaconDropshipBugOut

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if activeDropships[unitID] then
		--Spring.Echo("Oh noes, my dropship! Send the next one", attackerID, attackerDefID, attackerTeam)
		BeaconFree(activeDropships[unitID], teamID)
		activeDropships[unitID] = nil
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == BEACON_ID then
		BeaconDropshipBugOut(unitID, oldTeam)
	end
end


function gadget:Initialize()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

end
