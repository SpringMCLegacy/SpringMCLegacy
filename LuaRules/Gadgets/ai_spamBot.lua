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
local BEACON_ID = UnitDefNames["beacon"].id
local C3_ID = UnitDefNames["upgrade_c3array"].id
--local DelayCall = GG.Delay.DelayCall
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local CMD_C3 = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_c3array")
local dropZoneIDs = {}
local orderSizes = {}

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

function gadget:GamePreload()
	-- Initialise unit limit for all AI teams.
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		if Spring.GetTeamLuaAI(t) ==  name then
			AI_TEAMS[t] = true
		end
	end
end

local function SendOrder(teamID)
	local unitID = dropZoneIDs[teamID]
	local readyFrame = GG.coolDowns[teamID] or 0 --Spring.GetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN") or 0
	local frameDelay = math.max(readyFrame - Spring.GetGameFrame(), 0)
	if frameDelay == 0 and Spring.ValidUnitID(unitID) then
		orderSizes[teamID] = 0
		Spring.GiveOrderToUnit(unitID, CMD_SEND_ORDER, {}, {})
	else
		--Spring.Echo("Can't SEND_ORDER until", readyFrame, "(", frameDelay, ")")
		GG.Delay.DelayCall(SendOrder, {teamID}, frameDelay + 30)
	end
end

local function Spam(teamID)
	local unitID = dropZoneIDs[teamID]
	Spring.AddTeamResource(teamID, "metal", 10000000)
	local cmdDescs = Spring.GetUnitCmdDescs(unitID)
	orderSizes[teamID] = 0
	while orderSizes[teamID] < GG.teamSlotsRemaining[teamID] do
		local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
		if cmdDesc.id < 0 then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmdDesc.id, {}, {}}, 1)
			orderSizes[teamID] = orderSizes[teamID] + 1
			--Spring.Echo(orderSizes[teamID], cmdDesc.name, GG.teamSlotsRemaining[teamID])
		end
	end
	--orderSizes[teamID] = 0
	--GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_SEND_ORDER, {}, {}}, 1)
	local readyFrame = GG.coolDowns[teamID] or 0 --Spring.GetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN") or 0
	local frameDelay = 0 --math.max(readyFrame - Spring.GetGameFrame(), 0)
	GG.Delay.DelayCall(SendOrder, {teamID}, frameDelay + 30)
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if unitDefID == BEACON_ID then
		local x,_,z = Spring.GetUnitPosition(unitID)
		table.insert(flagSpots, {x = x, z = z})
	end
	if AI_TEAMS[teamID] then
		local unitDef = UnitDefs[unitDefID]
		if unitDef.name:find("dropzone") then
			dropZoneIDs[teamID] = unitID	
			Spam(teamID)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		Spam(teamID)
		if unitDefID == C3_ID then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {tonumber(Spring.GetUnitRulesParam(unitID, "beaconID")), CMD_C3, {}, {}}, 1)
		end
	end
end

local function Wander(unitID)
	if Spring.ValidUnitID(unitID) then
		local spot = flagSpots[math.random(1, #flagSpots)]
		local offsetX = math.random(50, 150)
		local offsetZ = math.random(50, 150)
		offsetX = offsetX * -1 ^ (offsetX % 2)
		offsetZ = offsetZ * -1 ^ (offsetZ % 2)
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.FIGHT, {spot.x + offsetX, 0, spot.z + offsetZ}, {}}, 1)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if AI_TEAMS[teamID] then
		if unitDefID == C3_ID then
			--Spring.Echo("C3!")
			Spam(teamID)
		elseif UnitDefs[unitDefID].canFly then
			--Spring.Echo("VTOL!")
			for _, spot in pairs(flagSpots) do
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.PATROL, {spot.x, 0, spot.z}, {"shift"}}, 30)
			end
		else
			--Spring.Echo("VEHICLE OR MECH!")
			Wander(unitID)
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if AI_TEAMS[newTeam] then
		if unitDefID == BEACON_ID then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_C3, {}, {}}, 1)
		end
	end
end

function gadget:UnitIdle(unitID, unitDefID, unitTeam)
	if UnitDefs[unitDefID].customParams.unittype then
		-- random chance a idle unit will wander somewhere else
		local chance = math.random(1, 100)
		if chance < 75 then
			--Spring.Echo(UnitDefs[unitDefID].name .. [[ "Fuck it, I'm off for a wander"]])
			GG.Delay.DelayCall(Wander, {unitID}, 30 * 6)
		else
			--Spring.Echo(UnitDefs[unitDefID].name .. [[ "I think I'll stay here..."]])
		end
	end
end

else
--	UNSYNCED
end
