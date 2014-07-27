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

local modOptions = Spring.GetModOptions()
local difficulty = tonumber(modOptions and modOptions.ai_difficulty or "1")

local DIREWOLF_ID = UnitDefNames["cl_direwolf_prime"].id
local DEVASTATOR_ID = UnitDefNames["is_devastator_dvs2"].id


local AI_TEAMS = {}
local BEACON_ID = UnitDefNames["beacon"].id
local C3_ID = UnitDefNames["upgrade_c3array"].id
--local DelayCall = GG.Delay.DelayCall
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")

local PERK_JUMP_RANGE = GG.CustomCommands.GetCmdID("PERK_JUMP_RANGE")

local CMD_C3 = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_c3array")
local dropZoneIDs = {}
local orderSizes = {}
local sides = {}

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
	if Spring.ValidUnitID(unitID) then
		Spring.AddTeamResource(teamID, "metal", 10000000)
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		orderSizes[teamID] = 0
		while orderSizes[teamID] < GG.teamSlotsRemaining[teamID] do
			local buildID
			if difficulty > 1 then
				buildID = (sides[teamID] == "clans" and -DIREWOLF_ID) or -DEVASTATOR_ID
				Spring.AddTeamResource(teamID, "energy", 100)
			else
				local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
				buildID = cmdDesc.id
			end
			if buildID < 0 then
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, buildID, {}, {}}, 1)
				orderSizes[teamID] = orderSizes[teamID] + 1
				--Spring.Echo("Adding to order;", orderSizes[teamID], UnitDefs[-buildID].name, GG.teamSlotsRemaining[teamID])
			end
		end
		GG.Delay.DelayCall(SendOrder, {teamID}, 2) -- frame after orders
	end
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
			sides[teamID] = unitDef.name:find("cl") and "clans" or "IS"
			Spam(teamID)
		end
		if difficulty > 1 then -- harder AI tonnage cheats, needs storage to do so
			Spring.SetTeamResource(teamID, "es", 1000000)
			Spring.AddTeamResource(teamID, "energy", 1000000)
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

local function Wander(unitID, cmd)
	if Spring.ValidUnitID(unitID) then
		local spot = flagSpots[math.random(1, #flagSpots)]
		local offsetX = math.random(50, 150)
		local offsetZ = math.random(50, 150)
		offsetX = offsetX * -1 ^ (offsetX % 2)
		offsetZ = offsetZ * -1 ^ (offsetZ % 2)
		if cmd then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmd, {spot.x + offsetX, 0, spot.z + offsetZ}, {}}, 1)
		end
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.FIGHT, {spot.x + offsetX, 0, spot.z + offsetZ}, {"shift"}}, 1)
	end
end

local function Perk(unitID, perkID)
	if not perkID then
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
		while not cmdDesc.action:find("perk") do
			cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
		end
		perkID = cmdDesc.id
	end
	GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, perkID, {}, {}}, 1)
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if AI_TEAMS[teamID] then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		if unitDefID == C3_ID then
			--Spring.Echo("C3!")
			Spam(teamID)
		elseif ud.canFly then
			--Spring.Echo("VTOL!")
			for _, spot in pairs(flagSpots) do
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.PATROL, {spot.x, 0, spot.z}, {"shift"}}, 30)
			end
		elseif cp.canjump then
			--Spring.Echo("JUMP MECH!")
			Wander(unitID, CMD_JUMP)
			Perk(unitID, PERK_JUMP_RANGE)
		else
			--Spring.Echo("VEHICLE OR MECH!")
			Wander(unitID)
			if cp.unittype == "mech" then
				Perk(unitID)
			end
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

function gadget:UnitIdle(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		if cp.unittype then
			-- random chance a idle unit will wander somewhere else
			local chance = math.random(1, 100)
			if chance < 75 then
				--Spring.Echo(UnitDefs[unitDefID].name .. [[ "Fuck it, I'm off for a wander"]])
				GG.Delay.DelayCall(Wander, {unitID, cp.canjump and CMD_JUMP}, 30 * 25)
			else
				--Spring.Echo(UnitDefs[unitDefID].name .. [[ "I think I'll stay here..."]])
			end
		end
	end
end

else
--	UNSYNCED
end
