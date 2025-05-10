function gadget:GetInfo()
	return {
		name		= "Outpost - C3 Array",
		desc		= "Controls mech lances",
		author		= "FLOZi (C. Lawrence)",
		date		= "25/07/20",
		license 	= "GNU GPL v2",
		layer		= 3,
		enabled	= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam

-- Constants
local EMPTY_TABLE = {} -- keep as empty
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local C3_ID = UnitDefNames["outpost_c3array"].id

-- Variables
local C3Status = {} -- C3Status[unitID] = bool deployed
local teamC3Counts = {} -- teamC3Counts[teamID] = number
local teamSlots = {} -- teamSlots[teamID] = {[1] = {active = true, used = number, available = number, units = {unitID1 = tons, unitID2 = tons, ...}}, ...}
local unitLances = {} -- unitLances[unitID] = group_number

local function TeamSlotsRemaining(teamID)
	local slots = 0
	for i = 1, 3 do
		-- we only want to consider slots in lances we actively control
		slots = slots + ((teamSlots[teamID][i].active and math.floor(teamSlots[teamID][i].available)) or 0)
	end
	return slots
end
GG.TeamSlotsRemaining = TeamSlotsRemaining

local function TeamAvailableGroup(teamID, size)
	if select(3, Spring.GetTeamInfo(teamID)) then return false end -- team died
	if teamID == GAIA_TEAM_ID then return false end
	for lance = 1, 3 do
		if teamSlots[teamID][lance].available == nil or size == nil then Spring.Echo("FLOZi Logic Fail C3 line 47", teamSlots[teamID][lance].available, size) return false end
		if teamSlots[teamID][lance].available >= size then return lance, teamSlots[teamID][lance].active end
	end
	return false
end

local function ToggleLink(unitID, teamID, lost)
	if lost then
		SendToUnsynced("TOGGLE_SELECT", unitID, teamID, false)
		Spring.SetUnitRulesParam(unitID, "LOST_LINK", 1, {inlos = true})
	else
		SendToUnsynced("TOGGLE_SELECT", unitID, teamID, true)
		Spring.SetUnitRulesParam(unitID, "LOST_LINK", 0, {inlos = true})
	end
end
GG.ToggleLink = ToggleLink

function TonnageSort(a, b)
	return a.tonnage > b.tonnage
end

local function AssignGroup(unitID, unitDefID, teamID, slotChange, group)
	local groupSlots = teamSlots[teamID][group]
	if groupSlots then -- can be called to remove from a dead group
		groupSlots.used = groupSlots.used + slotChange
		groupSlots.available = groupSlots.available - slotChange
	end
	if slotChange > 0 then -- adding a unit to group
		unitLances[unitID] = group
		--Spring.Echo("AssignGroup 1. Team:", teamID, "Group:", group, slotChange, groupSlots.available)
		SendToUnsynced("LANCE", teamID, unitID, group)
		Spring.SetUnitRulesParam(unitID, "LANCE", group)
		groupSlots.units[unitID] = UnitDefs[unitDefID].energyCost
	else -- removing a unit from a group
		groupSlots.units[unitID] = nil
		unitLances[unitID] = nil
		-- iterate through existing link lost mechs to see if they will fit into this group (TODO: tonnage also an issue)
		local candidates = {}
		local numCandidates = 0
		for groupNum, currGroupSlots in ipairs(teamSlots[teamID]) do
			-- lance is higher than the one that lost a unit
			-- AND it has units assigned to it
			-- AND the team has inssufficient C3's to support it
			if groupNum > group and currGroupSlots.used > 0 and (teamC3Counts[teamID] + 1) < groupNum then
				for groupUnitID, unitTonnage in pairs(currGroupSlots.units) do
					local linkLost = (Spring.GetUnitRulesParam(groupUnitID, "LOST_LINK") or 0) == 1
					if linkLost then
						numCandidates = numCandidates + 1
						candidates[groupUnitID] = {id = groupUnitID, tonnage = unitTonnage}
						--[[if numCandidates == groupSlots.available then
							break -- no point continuing if we already have enough mechs to fill the lance
						end]]
					end
				end
			end
		end
		-- TODO: Probably a FILO queue is better here?
		-- sort by tonnage (descending) -- TODO: Is this even still needed after splitting tonnage and lancing? Probably you want to prioritise heaviest mechs
		table.sort(candidates, TonnageSort)
		-- we don't want to change the list as we iterate over it so build a list of candidates first then iterate over that making the changes
		-- use a first-fit decreasing bin packing algorithm
		local numAssigned = 0
		for i, candidate in pairs(candidates) do
			if numAssigned < groupSlots.available then -- unit will fit
				unitLances[candidate.id] = group
				ToggleLink(candidate.id, teamID, false)
				--Spring.Echo("AssignGroup 2. Team:", teamID, "Group:", group, numAssigned, groupSlots.available)
				SendToUnsynced("LANCE", teamID, candidate.id, group)
				numAssigned = numAssigned + 1
			end
		end
	end
end

function LanceControl(teamID, unitID, add)
	if teamID == GAIA_TEAM_ID then return end -- no need to track for gaia
	if add then
		C3Status[unitID] = true
		teamC3Counts[teamID] = teamC3Counts[teamID] + 1
		--Spring.Echo(teamID, "C3 Count INCREASE", teamC3Counts[teamID])
		if teamC3Counts[teamID] <= 2 then -- only the first 2 C3s give you an extra lance
			local newLance = teamC3Counts[teamID] + 1
			Spring.SendMessageToTeam(teamID, "Gained lance #" .. newLance)
			Spring.SetTeamRulesParam(teamID, "LANCES", newLance)
			local groupSlots = teamSlots[teamID][newLance]
			groupSlots.active = true
			-- If there were any mechs in this lance, make them selectable again
			for unitID in pairs(groupSlots.units) do
				ToggleLink(unitID, teamID, false)
			end
		end
	elseif C3Status[unitID] then -- lost a deployed C3
		teamC3Counts[teamID] = teamC3Counts[teamID] - 1
		-- check if there were any backup C3 towers
		--Spring.Echo(teamID, "C3 Count DECREASE", teamC3Counts[teamID])
		if teamC3Counts[teamID] < 2 then -- team lost control of / capacity for a lance
			local lostLance = teamC3Counts[teamID] + 2
			Spring.SendMessageToTeam(teamID, "Lost lance #" .. lostLance)
			Spring.SetTeamRulesParam(teamID, "LANCES", lostLance - 1)
			local groupSlots = teamSlots[teamID][lostLance]
			groupSlots.active = false
			-- stop any mechs in this lance and make them unselectable
			--Spring.GiveOrderToUnitMap(groupSlots.units, CMD.STOP, EMPTY_TABLE, EMPTY_TABLE)
			for unitID, tonnage in pairs(groupSlots.units) do
				local unitDefID = Spring.GetUnitDefID(unitID) -- TODO: somehow, this can be nil? unitID is dead?
				if unitDefID then -- work around the bug for now
					local lowerGroup, lowerActive = TeamAvailableGroup(teamID, 1)
					if lowerGroup and lowerActive then -- if there is a slot lower down, take it
						-- cleanup old group
						AssignGroup(unitID, unitDefID, teamID, -1, unitLances[unitID])
						-- add to new group
						AssignGroup(unitID, unitDefID, teamID, 1, lowerGroup)
					else -- otherwise we've lost the link
						ToggleLink(unitID, teamID, true, tonnage)
					end
				end
			end
		end
		C3Status[unitID] = nil
	end
end
GG.LanceControl = LanceControl

local function UpdateTeamSlots(teamID, unitID, unitDefID, add)
	if select(3,Spring.GetTeamInfo(teamID)) or teamID == GAIA_TEAM_ID then return end -- team died
	local ud = UnitDefs[unitDefID]
	if add then -- new unit
		local group, active = TeamAvailableGroup(teamID, 1)
		if group then
			if not active then 
				--Spring.Echo(teamID, "Assigned to an inactive group!") 
				ToggleLink(unitID, teamID, true, ud.energyCost)
			end
			AssignGroup(unitID, unitDefID, teamID, 1, group)
		else 
			Spring.Echo(teamID, "FLOZi logic fail: No available group", TeamSlotsRemaining(teamID), 1, ud.name) -- TODO: can reach here
		end
	else -- unit died
		local group = unitLances[unitID]
		AssignGroup(unitID, unitDefID, teamID, -1, group)
	end
	Spring.SetTeamRulesParam(teamID, "TEAM_SLOTS_REMAINING", TeamSlotsRemaining(teamID))
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if GG.mechCache[unitDefID] then
		local group = unitLances[unitID]
		local groupSlots = teamSlots[teamID][group]
		if groupSlots then
			if not groupSlots.active then 
				return false -- strictly no commands to lost link units
			end
		end
		return true -- allow all other commands through here
	end
	return true
end


function gadget:UnitCreated(unitID, unitDefID, teamID)
	local unitDef = UnitDefs[unitDefID]
	if GG.mechCache[unitDefID] then
		UpdateTeamSlots(teamID, unitID, unitDefID, true)
	end
end


function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if unitDefID == C3_ID then
		LanceControl(teamID, unitID, false)
	elseif GG.mechCache[unitDefID] then
		UpdateTeamSlots(teamID, unitID, unitDefID, false)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if GG.mechCache[unitDefID] then
		UpdateTeamSlots(oldTeam, unitID, unitDefID, false)
	end
	if newTeam ~= GAIA_TEAM_ID then
		gadget:UnitCreated(unitID, unitDefID, newTeam)
		if unitDefID == C3_ID then
			LanceControl(newTeam, unitID, true)
		end
	end
end


function gadget:Initialize()
	for _, teamID in pairs(Spring.GetTeamList()) do
		teamSlots[teamID] = {}
		teamC3Counts[teamID] = 0
		for i = 1, 3 do
			teamSlots[teamID][i] = {}
			teamSlots[teamID][i].active = i == 1
			teamSlots[teamID][i].used = 0
			teamSlots[teamID][i].available = 4
			teamSlots[teamID][i].units = {}
		end
	end
		for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

local MY_TEAM_ID = Spring.GetMyTeamID()

-- used when link is lost and also for vehicles
function ToggleSelectionByTeam(eventID, unitID, teamID, selectable)
	if teamID == MY_TEAM_ID and not (GG.AI_TEAMS and GG.AI_TEAMS[teamID]) and not Spring.GetSpectatingState() then
		Spring.SetUnitNoSelect(unitID, not selectable)
	end
end

function AddUnitToLance(eventID, teamID, unitID, group)
	if teamID == MY_TEAM_ID then
		CallAsTeam(teamID, Spring.SetUnitGroup, unitID, group)
		Script.LuaUI.SetLance(unitID, group)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("LANCE", AddUnitToLance)
	gadgetHandler:AddSyncAction("TOGGLE_SELECT", ToggleSelectionByTeam)
end

end
