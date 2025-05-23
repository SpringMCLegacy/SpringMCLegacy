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
local unitLances = {} -- unitLances[unitID] = lance_number

local function TeamSlotsRemaining(teamID)
	local slots = 0
	for i = 1, 3 do
		-- we only want to consider slots in lances we actively control
		slots = slots + ((teamSlots[teamID][i].active and math.floor(teamSlots[teamID][i].available)) or 0)
	end
	return slots
end
GG.TeamSlotsRemaining = TeamSlotsRemaining

local function TeamAvailableLance(teamID, size)
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

local function AddToLance(unitID, teamID, lance, tonnage)
	unitLances[unitID] = lance
	local lanceSlots = teamSlots[teamID][lance]
	lanceSlots.units[unitID] = tonnage
	lanceSlots.used = lanceSlots.used + 1
	lanceSlots.available = lanceSlots.available - 1
	--Spring.Echo("AddToLance. Team:", teamID, "lance:", lance, "available:", lanceSlots.available, "used:", lanceSlots.used , UnitDefs[Spring.GetUnitDefID(unitID)].name, unitID)
	-- Send info through to Unsynced
	SendToUnsynced("LANCE", teamID, unitID, lance, false)
	Spring.SetUnitRulesParam(unitID, "LANCE", lance)
end

local function RemoveFromLance(unitID, teamID, lance)
	unitLances[unitID] = nil
	local lanceSlots = teamSlots[teamID][lance]
	lanceSlots.units[unitID] = nil
	lanceSlots.used = lanceSlots.used - 1 
	lanceSlots.available = lanceSlots.available + 1
	--Spring.Echo("RemoveToLance. Team:", teamID, "lance:", lance, "available:", lanceSlots.available, "used:", lanceSlots.used , UnitDefs[Spring.GetUnitDefID(unitID)].name, unitID)
	-- Send info through to Unsynced
	SendToUnsynced("LANCE", teamID, unitID, lance, true)
	Spring.SetUnitRulesParam(unitID, "LANCE", "")
end

-- when a mech dies SD(teamID, thatMech'sLance), when C3 dies call SD(teamID, lanceBelowC3)
local function ShuffleDown(teamID, lanceNumWithSlot)
	-- iterate through existing link lost mechs to see if they will fit into this lance (TODO: tonnage also an issue)
	local candidates = {}
	local numCandidates = 0
	for lanceNum, currlanceSlots in ipairs(teamSlots[teamID]) do
		-- lance is higher than the one that lost a unit
		-- AND it has units assigned to it
		-- AND the team has inssufficient C3's to support it
		if lanceNum > lanceNumWithSlot and currlanceSlots.used > 0 and (teamC3Counts[teamID] + 1) < lanceNum then
			-- we don't want to change the list as we iterate over it so build a list of candidates first...
			for lanceUnitID, unitTonnage in pairs(currlanceSlots.units) do
				numCandidates = numCandidates + 1
				candidates[lanceUnitID] = {id = lanceUnitID, tonnage = unitTonnage, currLance = lanceNum}
			end
		end
		-- sort by tonnage, probably you want to prioritise heaviest mechs
		table.sort(candidates, TonnageSort)
		-- ... then iterate over that making the changes
		local newLance = teamSlots[teamID][lanceNumWithSlot]
		local numAssigned = 0
		local available = newLance.available -- cache incase it changes whilst iterating
		for i, candidate in pairs(candidates) do
			if numAssigned < available then -- unit will fit
				ToggleLink(candidate.id, teamID, false) -- moving into an active lance, activate the link
				--Spring.Echo("ShuffleDown candidate team:", teamID, "into lance:", lanceNumWithSlot, "from lance", candidate.currLance, UnitDefs[Spring.GetUnitDefID(candidate.id)].name, candidate.id)
				RemoveFromLance(candidate.id, teamID, candidate.currLance)
				AddToLance(candidate.id, teamID, lanceNumWithSlot, candidate.tonnage)
				numAssigned = numAssigned + 1
			end
		end
	end
end

local function AssignLance(unitID, unitDefID, teamID, slotChange, lance)
	if slotChange > 0 then -- adding a unit to lance
		AddToLance(unitID, teamID, lance, UnitDefs[unitDefID].energyCost)
	else -- removing a unit from a lance
		RemoveFromLance(unitID, teamID, lance)
		-- Check if this has made a gap to shuffle into
		--Spring.Echo("AssignLance (mech died) Shuffle team:", teamID, "lanceNumWithSlot", lance)
		ShuffleDown(teamID, lance)
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
			SendToUnsynced("MAX_LANCE", teamID, newLance)
			local lanceSlots = teamSlots[teamID][newLance]
			lanceSlots.active = true
			-- If there were any mechs in this lance, make them selectable again
			for unitID in pairs(lanceSlots.units) do
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
			SendToUnsynced("MAX_LANCE", teamID, lostLance - 1)
			local lanceSlots = teamSlots[teamID][lostLance]
			lanceSlots.active = false
			-- first check if we can shuffle any down
			for i = (lostLance - 1), 1, -1 do
				--Spring.Echo("LanceControl (C3 died) Shuffle team:", teamID, "lanceToCheck", i)
				ShuffleDown(teamID, i)
			end
			-- stop any mechs remaining in this lance and make them unselectable
			--Spring.GiveOrderToUnitMap(lanceSlots.units, CMD.STOP, EMPTY_TABLE, EMPTY_TABLE)
			for unitID, tonnage in pairs(lanceSlots.units) do
				ToggleLink(unitID, teamID, true, tonnage)
			end
		end
		-- cleanup the C3 itself
		C3Status[unitID] = nil
	end
end
GG.LanceControl = LanceControl

local function UpdateTeamSlots(teamID, unitID, unitDefID, add)
	if select(3,Spring.GetTeamInfo(teamID)) or teamID == GAIA_TEAM_ID then return end -- team died
	local ud = UnitDefs[unitDefID]
	if add then -- new unit
		local lance, active = TeamAvailableLance(teamID, 1)
		if lance then
			if not active then 
				--Spring.Echo(teamID, "Assigned to an inactive lance!") 
				ToggleLink(unitID, teamID, true, ud.energyCost)
			end
			AssignLance(unitID, unitDefID, teamID, 1, lance)
		else 
			Spring.Echo(teamID, "FLOZi logic fail: No available lance", TeamSlotsRemaining(teamID), 1, ud.name) -- TODO: can reach here
		end
	else -- unit died
		local lance = unitLances[unitID]
		AssignLance(unitID, unitDefID, teamID, -1, lance)
	end
	Spring.SetTeamRulesParam(teamID, "TEAM_SLOTS_REMAINING", TeamSlotsRemaining(teamID))
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if GG.mechCache[unitDefID] then
		local lance = unitLances[unitID]
		local lanceSlots = teamSlots[teamID][lance]
		if lanceSlots then
			if not lanceSlots.active then 
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
		Spring.SetTeamRulesParam(teamID, "LANCES", 1) 
	end
		for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

-- used when link is lost and also for vehicles
function ToggleSelectionByTeam(eventID, unitID, teamID, selectable)
	if teamID == Spring.GetMyTeamID() and not (GG.AI_TEAMS and GG.AI_TEAMS[teamID]) and not Spring.GetSpectatingState() then
		Spring.SetUnitNoSelect(unitID, not selectable)
	end
end

function AddUnitToLance(eventID, teamID, unitID, lance, clean)
	--Spring.Echo("AddUnitToLance team:", teamID, "unit:", unitID, "lance:", lance, "clean", clean)
	if teamID == Spring.GetMyTeamID() then
		if clean then
			Script.LuaUI.CleanLance(unitID, lance)
		elseif unitID then 
			CallAsTeam(teamID, Spring.SetUnitGroup, unitID, lance)
			Script.LuaUI.SetLance(unitID, lance)
		end
	end
end

function SetMaxLance(eventID, teamID, maxLance)
	if teamID == Spring.GetMyTeamID() then
		Script.LuaUI.SetMaxLance(maxLance)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("LANCE", AddUnitToLance)
	gadgetHandler:AddSyncAction("MAX_LANCE", SetMaxLance)
	gadgetHandler:AddSyncAction("TOGGLE_SELECT", ToggleSelectionByTeam)
end

end
