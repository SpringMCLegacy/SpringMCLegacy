function gadget:GetInfo()
	return {
		name		= "SpamBot",
		desc		= "Spam",
		author		= "FLOZi (C. Lawrence)",
		date		= "19/07/14",
		license 	= "GNU GPL v2",
		layer		= 10,
		enabled	= true,	--	loaded by default?
	}
end



if gadgetHandler:IsSyncedCode() then
--	SYNCED
local AI_TEAMS = {}

--local DelayCall = GG.Delay.DelayCall
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local dropZoneIDs = {}
local orderSizes = {}

local flagSpots = VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

function gadget:GamePreload()
	-- Initialise unit limit for all AI teams.
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) ==  name then
			AI_TEAMS[t] = true
		end
	end
end

local function Spam(unitID, teamID)
	Spring.AddTeamResource(teamID, "metal", 100000)
	Spring.AddTeamResource(teamID, "energy", 100000)
	for i, cmdDesc in pairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id < 0 then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmdDesc.id, {}, {}}, 1)
			orderSizes[teamID] = (orderSizes[teamID] or 0) + 1
		end
	end
	if orderSizes[teamID] > 4 then
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_SEND_ORDER, {}, {}}, 30)
		orderSizes[teamID] = 0
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		local unitDef = UnitDefs[unitDefID]
		if unitDef.name:find("dropzone") then
			dropZoneIDs[teamID] = unitID	
			Spam(unitID, teamID)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		Spam(dropZoneIDs[teamID], teamID)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if AI_TEAMS[unitTeam] then
		local spot = flagSpots[math.random(1, #flagSpots)]
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.FIGHT, {spot.x, 0, spot.z}, {}}, 30)
	end
end

else
--	UNSYNCED
end
