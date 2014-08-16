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
local ATLAS_ID = UnitDefNames["is_atlas_as7k"].id

local SHADOWCAT_ID = UnitDefNames["cl_shadowcat_prime"].id
local OSIRIS_ID = UnitDefNames["is_osiris_osr3d"].id

local AI_TEAMS = {}
local BEACON_ID = UnitDefNames["beacon"].id
local C3_ID = UnitDefNames["upgrade_c3array"].id
local VPAD_ID = UnitDefNames["upgrade_vehiclepad"].id
--local DelayCall = GG.Delay.DelayCall
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")
local CMD_MASC = GG.CustomCommands.GetCmdID("CMD_MASC")

local PERK_JUMP_RANGE = GG.CustomCommands.GetCmdID("PERK_JUMP_RANGE")

local CMD_C3 = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_c3array")
local CMD_VPAD = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_vehiclepad")

local dropZoneIDs = {}
local orderSizes = {}
local sides = {}

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local teamUpgradeCounts = {} -- teamUpgradeCounts[teamID] = {c3 = 1, vpad = 1} etc

function gadget:GamePreload()
	-- Initialise unit limit for all AI teams.
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		teamUpgradeCounts[t] = {}
		teamUpgradeCounts[t][C3_ID] = 0
		teamUpgradeCounts[t][VPAD_ID] = 0
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
		while orderSizes[teamID] < GG.TeamSlotsRemaining(teamID) do
			--Spring.Echo("COMPARING:", orderSizes[teamID], GG.TeamSlotsRemaining(teamID))
			local buildID
			if difficulty > 1 then
				if difficulty == 3 then
					buildID = (sides[teamID] == "clans" and -DIREWOLF_ID) or -ATLAS_ID
				elseif difficulty == 2 then
					buildID = (sides[teamID] == "clans" and -SHADOWCAT_ID) or -OSIRIS_ID
				end
				Spring.AddTeamResource(teamID, "energy", 100)
			else
				local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
				buildID = cmdDesc.id
			end
			if buildID < 0 then
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, buildID, {}, {}}, 1)
				orderSizes[teamID] = orderSizes[teamID] + 1
				--Spring.Echo("Adding to order;", orderSizes[teamID], UnitDefs[-buildID].name, GG.TeamSlotsRemaining(teamID))
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

local function RunAndJump(unitID, unitDefID)
	if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then return end
	local jumpLength = 900 -- TODO: unhardcode this
	local jumpReload = 10
	local speed = UnitDefs[unitDefID].speed
	local distCovered = speed * jumpReload
	-- find target
	local spot = flagSpots[math.random(1, #flagSpots)]
	local offsetX = math.random(50, 150)
	local offsetZ = math.random(50, 150)
	offsetX = offsetX * -1 ^ (offsetX % 2)
	offsetZ = offsetZ * -1 ^ (offsetZ % 2)
	local target = {x = spot.x + offsetX, z = spot.z + offsetZ}
	local cx, _, cz = Spring.GetUnitPosition(unitID)
	local targetVector = {x = target.x - cx, z = target.z - cz}
	local targetVectorLength = math.sqrt(targetVector.x^2 + targetVector.z^2)
	
	local distToTarget = GG.GetUnitDistanceToPoint(unitID, target.x, Spring.GetGroundHeight(target.x,target.z), target.z, true)
	local numSteps = math.floor(distToTarget / (jumpLength + distCovered)) * 2
	targetVector.x = targetVector.x / targetVectorLength
	targetVector.z = targetVector.z / targetVectorLength
	
	local x = cx
	local z = cz
	for i = 1, numSteps, 2 do
		x = x + targetVector.x*distCovered
		z = z + targetVector.z*distCovered
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.MOVE, {x, Spring.GetGroundHeight(x,z), z}, {"shift"}}, 1)
		x = x + targetVector.x*jumpLength
		z = z + targetVector.z*jumpLength
		local y = Spring.GetGroundHeight(x,z)
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, y > 0 and CMD_JUMP or CMD.MOVE, {x, y, z}, {"shift"}}, 1)
	end
	-- make sure last command is a jump onto beacon
	GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_JUMP, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}, 1)
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

local function UnitIdleCheck(unitID, unitDefID, teamID)
	if Spring.GetUnitIsDead(unitID) then return false end
	local cmdQueueSize = Spring.GetCommandQueue(unitID, -1, false) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo("I'm so not idle!") 
		return
	end
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp.unittype then
		-- random chance a idle unit will wander somewhere else
		local chance = math.random(1, 100)
		if chance < 75 then
			--Spring.Echo(UnitDefs[unitDefID].name .. [[ "Fuck it, I'm off for a wander"]])
			if cp.canjump then
				GG.Delay.DelayCall(RunAndJump, {unitID, unitDefID}, 30 * 25)
			else
				GG.Delay.DelayCall(Wander, {unitID}, 30 * 25)
			end
		else
			--Spring.Echo(UnitDefs[unitDefID].name .. [[ "I think I'll stay here..."]])
		end
	end
end

	
function gadget:UnitIdle(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 10)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if AI_TEAMS[teamID] then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		if unitDefID == C3_ID then
			teamUpgradeCounts[teamID][C3_ID] = teamUpgradeCounts[teamID][C3_ID] + 1
			--Spring.Echo("C3!")
			-- C3's take a little time to deploy and grant the extra tonnage & slots, so delay 10s
			GG.Delay.DelayCall(Spam, {teamID}, 10 * 30)
			for k,v in pairs(Spring.GetTeamUnits(teamID)) do
				GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 10 * 30)
			end
		elseif unitDefID == VPAD_ID then
			teamUpgradeCounts[teamID][VPAD_ID] = teamUpgradeCounts[teamID][VPAD_ID] + 1
		elseif ud.canFly then
			--Spring.Echo("VTOL!")
			for _, spot in pairs(flagSpots) do
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.PATROL, {spot.x, 0, spot.z}, {"shift"}}, 30)
			end
		elseif cp.canjump then
			--Spring.Echo("JUMP MECH!")
			Perk(unitID, PERK_JUMP_RANGE)
			RunAndJump(unitID, unitDefID)
		else
			--Spring.Echo("VEHICLE OR MECH!")
			Wander(unitID)
			if cp.unittype == "mech" then
				Perk(unitID)
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		if unitDefID == C3_ID then
			teamUpgradeCounts[teamID][C3_ID] = teamUpgradeCounts[teamID][C3_ID] - 1
		elseif unitDefID == VPAD_ID then
			teamUpgradeCounts[teamID][VPAD_ID] = teamUpgradeCounts[teamID][VPAD_ID] - 1
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if AI_TEAMS[newTeam] then
		if unitDefID == BEACON_ID then
			if (teamUpgradeCounts[newTeam][C3_ID] + teamUpgradeCounts[newTeam][VPAD_ID]) % 2 == 0 then -- even number of upgrades get another C3
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_C3, {}, {}}, 1)
			else
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_VPAD, {}, {}}, 1)
			end
		end
		if unitDefID == C3_ID or unitDefID == VPAD_ID then
			gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
			gadget:UnitUnloaded(unitID, unitDefID, newTeam)
		end
	end
end

else
--	UNSYNCED
end
