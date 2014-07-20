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
local CMD_C3 = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_c3array")
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
	Spring.AddTeamResource(teamID, "metal", 10000000)
	local cmdDescs = Spring.GetUnitCmdDescs(unitID)
	orderSizes[teamID] = 0
	while orderSizes[teamID] < GG.teamSlotsRemaining[teamID] do
		local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
		if cmdDesc.id < 0 then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmdDesc.id, {}, {}}, 1)
			orderSizes[teamID] = orderSizes[teamID] + 1
			--Spring.Echo(orderSizes[teamID], cmdDesc.name)
		end
	end
	local readyFrame = Spring.GetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN") or 0
	local frameDelay = math.max(readyFrame - Spring.GetGameFrame(), 0)
	GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_SEND_ORDER, {}, {}}, frameDelay + 30)
	orderSizes[teamID] = 0
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
		if unitDefID == UnitDefNames["upgrade_c3array"].id then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {tonumber(Spring.GetUnitRulesParam(unitID, "beaconID")), CMD_C3, {}, {}}, 1)
		end
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if AI_TEAMS[unitTeam] then
		local spot = flagSpots[math.random(1, #flagSpots)]
		local offsetX = math.random(50, 150)
		local offsetZ = math.random(50, 150)
		offsetX = offsetX * -1 ^ (offsetX % 2)
		offsetZ = offsetZ * -1 ^ (offsetZ % 2)
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.FIGHT, {spot.x + offsetX, 0, spot.z + offsetZ}, {}}, 30)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if AI_TEAMS[newTeam] then
		if unitDefID == UnitDefNames["beacon"].id then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_C3, {}, {}}, 1)
		end
	end
end

else
--	UNSYNCED
end
