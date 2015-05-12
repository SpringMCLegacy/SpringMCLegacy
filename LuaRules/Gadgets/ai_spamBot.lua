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
local IS_DROPZONE_ID = UnitDefNames["is_dropzone"].id
local CL_DROPZONE_ID = UnitDefNames["cl_dropzone"].id
local DROPZONE_IDS = {[IS_DROPZONE_ID] = true, [CL_DROPZONE_ID] = true}
local C3_ID = UnitDefNames["upgrade_c3array"].id
local VPAD_ID = UnitDefNames["upgrade_vehiclepad"].id
--local DelayCall = GG.Delay.DelayCall
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")
local CMD_MASC = GG.CustomCommands.GetCmdID("CMD_MASC")

local PERK_JUMP_RANGE = GG.CustomCommands.GetCmdID("PERK_JUMP_RANGE")

local CMD_DROPZONE = GG.CustomCommands.GetCmdID("CMD_DROPZONE")
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
	GG.AI_TEAMS = AI_TEAMS
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

local function Upgrade(unitID, newTeam)
	-- FIXME: ugly as sin
	if Spring.GetTeamUnitDefCount(newTeam, IS_DROPZONE_ID) + Spring.GetTeamUnitDefCount(newTeam, CL_DROPZONE_ID) == 0 then
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_DROPZONE, {}, {}}, 1)
	elseif (teamUpgradeCounts[newTeam][C3_ID] + teamUpgradeCounts[newTeam][VPAD_ID]) % 2 == 0 then -- even number of upgrades get another C3
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_C3, {}, {}}, 1)
	else
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_VPAD, {}, {}}, 1)
	end
end

local function RunAndJump(unitID, unitDefID, cmdID, spotNum, replace)
	if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then return end
	cmdID = cmdID or CMD.MOVE
	local jumpLength = GG.jumpDefs[unitDefID].range
	local jumpReload = GG.jumpDefs[unitDefID].reload
	local speed = UnitDefs[unitDefID].speed
	local distCovered = speed * jumpReload
	-- find target
	local spot = flagSpots[spotNum or math.random(1, #flagSpots)]
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
	local y = Spring.GetGroundHeight(x,z)
	local orderArray = {}
	for i = 1, numSteps, 2 do
		x = x + targetVector.x*distCovered
		z = z + targetVector.z*distCovered
		y = Spring.GetGroundHeight(x,z)
		local order = {cmdID, {x, y, z}, {replace and "" or "shift"}}
		table.insert(orderArray, order)
		x = x + targetVector.x*jumpLength
		z = z + targetVector.z*jumpLength
		y = Spring.GetGroundHeight(x,z)
		order = {y > 0 and CMD_JUMP or cmdID, {x, y, z}, {"shift"}}
		table.insert(orderArray, order)
	end
	-- make sure last command is a jump onto beacon
	order = {CMD_JUMP, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}
	table.insert(orderArray, order)
	--GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_JUMP, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}, 1)
	Spring.GiveOrderArrayToUnitArray({unitID}, orderArray)
end
GG.RunAndJump = RunAndJump

local function Wander(unitID, cmd)
	if Spring.ValidUnitID(unitID) then
		local spot = flagSpots[math.random(1, #flagSpots)]
		local offsetX = math.random(50, 150)
		local offsetZ = math.random(50, 150)
		offsetX = offsetX * -1 ^ (offsetX % 2)
		offsetZ = offsetZ * -1 ^ (offsetZ % 2)
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.MOVE_STATE, {2}, {}}, 1)
		if cmd then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmd, {spot.x + offsetX, 0, spot.z + offsetZ}, {}}, 1)
		end
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.FIGHT, {spot.x + offsetX, 0, spot.z + offsetZ}, {"shift"}}, 1)
	end
end

local availablePerks = {} -- availablePerks[unitID] = {cmdDescID = true, ...}
local availablePerkCounts = {} -- availablePerkCounts[unitID] = number

local function Perk(unitID, perkID, firstTime)
	if firstTime then
		availablePerks[unitID] = {}
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		for id, cmdDesc in pairs(cmdDescs) do
			if cmdDesc.action:find("perk") then
				availablePerks[unitID][id] = true
				availablePerkCounts[unitID] = (availablePerkCounts[unitID] or 0) + 1
			end
		end
	end
	if Spring.GetUnitExperience(unitID) < 1.5 then return end
	if not perkID and availablePerkCounts[unitID] > 0 then
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		local ID = math.random(1, #cmdDescs)
		while not (availablePerks[unitID][ID]) do
			ID = math.random(1, #cmdDescs)
		end
		perkID = cmdDescs[ID].id
		availablePerks[unitID][ID] = false
		availablePerkCounts[unitID] = availablePerkCounts[unitID] - 1
	end
	if perkID then
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, perkID, {}, {}}, 1)
	end
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
				if not Spring.GetUnitRulesParam(unitID, "dronesout") == 1 then
					GG.Delay.DelayCall(Wander, {unitID}, 30 * 25)
				end
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
			Perk(unitID, PERK_JUMP_RANGE, true)
			RunAndJump(unitID, unitDefID)
		else
			--Spring.Echo("VEHICLE OR MECH!")
			Wander(unitID)
			if cp.unittype == "mech" then
				Perk(unitID, nil, true)
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if AI_TEAMS[teamID] then
		Spam(teamID)
		if unitDefID == C3_ID then
			teamUpgradeCounts[teamID][C3_ID] = teamUpgradeCounts[teamID][C3_ID] - 1
			Upgrade(tonumber(Spring.GetUnitRulesParam(unitID, "beaconID")), teamID)
		elseif unitDefID == VPAD_ID then
			teamUpgradeCounts[teamID][VPAD_ID] = teamUpgradeCounts[teamID][VPAD_ID] - 1
			Upgrade(tonumber(Spring.GetUnitRulesParam(unitID, "beaconID")), teamID)
		end
	end
	if attackerTeam and AI_TEAMS[attackerTeam] then
		Spam(attackerTeam)
		if attackerID and (UnitDefs[attackerDefID].customParams.unittype == "mech") then 
			Perk(attackerID) 
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if AI_TEAMS[newTeam] then
		if unitDefID == BEACON_ID then
			Upgrade(unitID, newTeam)
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
