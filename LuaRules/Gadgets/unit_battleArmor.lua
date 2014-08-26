function gadget:GetInfo()
	return {
		name		= "Battle Armor",
		desc		= "Infantry",
		author		= "FLOZi (C. Lawrence)",
		date		= "16/08/14",
		license 	= "GNU GPL v2",
		layer		= 10,
		enabled	= true,	--	loaded by default?
	}
end



if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()
--local DelayCall = GG.Delay.DelayCall
--local sides = {} -- teamID = is or clans

local APCs = {} -- APCs[unitID] = {team = teamID, cargo = {unitID1 = true, unitID2 = true, ...}, liveCount = 5}

local trooperAPCs = {} -- trooperAPCs[trooperID] = apcID

function gadget:Initialize()

end

local function SpawnCargo(unitID, teamID, capacity)
	local x,y,z = Spring.GetUnitPosition(unitID)
	env = Spring.UnitScript.GetScriptEnv(unitID)
	for i = 1, capacity do
		local trooperID = Spring.CreateUnit("cl_elemental_prime", x,y,z, 0, teamID)
		Spring.UnitScript.CallAsUnit(unitID, env.script.TransportPickup, trooperID)
		APCs[unitID].cargo[trooperID] = true
		APCs[unitID].liveCount = APCs[unitID].liveCount + 1
		trooperAPCs[trooperID] = unitID
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	if ud.name == "apc" then
		APCs[unitID] = {}
		APCs[unitID].team = teamID
		APCs[unitID].cargo = {}
		APCs[unitID].liveCount = 0
		SpawnCargo(unitID, teamID, ud.transportCapacity)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if UnitDefs[unitDefID].customParams.unittype == "infantry" then
		APCs[trooperAPCs[unitID]].liveCount = APCs[trooperAPCs[unitID]].liveCount - 1
	end
	-- TODO: remove from list to spawn at
end


--[[local function UnitIdleCheck(unitID, unitDefID, teamID)
	if Spring.GetUnitIsDead(unitID) then return false end
	local cmdQueueSize = Spring.GetCommandQueue(unitID, -1, false) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo("I'm so not idle!") 
		return
	end
	GG.Delay.DelayCall(Wander, {unitID}, 1)
end]]

local idleCount = {}

function gadget:UnitIdle(unitID, unitDefID, teamID)
	if UnitDefs[unitDefID].name == "cl_elemental_prime" then
		idleCount[unitID] = (idleCount[unitID] or 0) + 1
		if idleCount[unitID] == 2 then
			Spring.Echo("Elemental Idle", unitID)
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.LOAD_ONTO, {trooperAPCs[unitID]}, {}}, 1)
			idleCount[unitID] = 0
		end
	elseif UnitDefs[unitDefID].name == "apc" then
		local transporting = Spring.GetUnitIsTransporting(unitID)
		if #transporting == APCs[unitID].liveCount then
			GG.Wander(unitID)
		end
	end
end


function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)

end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)

end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)

	return true
end

else
--	UNSYNCED


end
