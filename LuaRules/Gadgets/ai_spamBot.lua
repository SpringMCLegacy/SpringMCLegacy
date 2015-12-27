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

local sideMechs = {} -- sideMechs[sideShortName] = {mechDefID1, mechDefID2, ...}
local sideJumpers = {} -- sideJumpers[sideShortName] = {jumperDefID1, jumperDefID2, ...}
local sideAssaults = {} -- sideAssaults[sideShortName] = {assaultDefID1, assaultDefID2, ...}

local AI_TEAMS = {}
local BEACON_ID = UnitDefNames["beacon"].id
local DROPZONE_IDS = GG.DROPZONE_IDS
local C3_ID = UnitDefNames["upgrade_c3array"].id
local VPAD_ID = UnitDefNames["upgrade_vehiclepad"].id
--local DelayCall = GG.Delay.DelayCall
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")
local CMD_MASC = GG.CustomCommands.GetCmdID("CMD_MASC")

local PERK_JUMP_RANGE = GG.CustomCommands.GetCmdID("PERK_JUMP_EFFICIENCY")

local CMD_DROPZONE = GG.CustomCommands.GetCmdID("CMD_DROPZONE")
local CMD_C3 = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_c3array")
local CMD_VPAD = GG.CustomCommands.GetCmdID("CMD_UPGRADE_upgrade_vehiclepad")

local dropZoneIDs = {}
local orderSizes = {}

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local teamUpgradeCounts = {} -- teamUpgradeCounts[teamID] = {c3 = 1, vpad = 1} etc

local function CostSort(unitDefID1, unitDefID2)
	return UnitDefs[unitDefID1].metalCost < UnitDefs[unitDefID2].metalCost
end

local function SimpleReverseSearch(sideTable, cost)
	for i = #sideTable, 1, -1 do
		local unitDefID = sideTable[i]
		local foundCost = UnitDefs[unitDefID].metalCost
		if foundCost < cost then return unitDefID end
	end
	return false -- no affordable mech!
end

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
	for unitDefID, unitDef in pairs(UnitDefs) do
		local side = unitDef.name:sub(1,2)
		-- identify all jump mechs by faction
		if unitDef.customParams.jumpjets then
			if not sideJumpers[side] then sideJumpers[side] = {} end
			table.insert(sideJumpers[side], unitDefID)
			--Spring.Echo("Adding jumper mech", unitDef.name, "to", side)
		end
		if unitDef.customParams.baseclass == "mech" then
			if not sideMechs[side] then sideMechs[side] = {} end
			table.insert(sideMechs[side], unitDefID)
			-- identify all assault mechs by faction
			if GG.GetWeight(tonumber(unitDef.customParams.tonnage) or 0) == "assault"  then
				if not sideAssaults[side] then sideAssaults[side] = {} end
				table.insert(sideAssaults[side], unitDefID)
				--Spring.Echo("Adding assault mech", unitDef.name, "to", side)
			end
		end
	end
	for side, mechTable in pairs(sideMechs) do
		table.sort(mechTable, CostSort)
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
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		local side = GG.teamSide[teamID]
		orderSizes[teamID] = 0
		while orderSizes[teamID] < GG.TeamSlotsRemaining(teamID) do
			--Spring.Echo("COMPARING:", orderSizes[teamID], GG.TeamSlotsRemaining(teamID))
			local buildID
			if difficulty > 1 then
				Spring.AddTeamResource(teamID, "metal", 10000000)
				if difficulty == 3 then -- Assaults only
					buildID = -sideAssaults[side][math.random(1, #sideAssaults[side])]
				elseif difficulty == 2 then -- jumpers only
					buildID = -sideJumpers[side][math.random(1, #sideJumpers[side])]
				end
				Spring.AddTeamResource(teamID, "energy", 100)
			else
				--local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
				buildID = SimpleReverseSearch(sideMechs[side], Spring.GetTeamResources(teamID, "metal") * 0.65)
			end
			if not buildID then return end -- couldn't find any affordable mechs
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, -buildID, {}, {}}, 1)
			orderSizes[teamID] = orderSizes[teamID] + 1
			--Spring.Echo("Adding to order;", orderSizes[teamID], UnitDefs[-buildID].name, GG.TeamSlotsRemaining(teamID))
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
			Spam(teamID)
		elseif unitDef.customParams.baseclass == "mech" then
			local closeRange = WeaponDefs[unitDef.weapons[1].weaponDef].range * 0.9
			-- set engagement range to weapon 1 range
			Spring.SetUnitMaxRange(unitID, closeRange)
		end
		if difficulty > 1 then -- harder AI tonnage cheats, needs storage to do so
			Spring.SetTeamResource(teamID, "es", 1000000)
			Spring.AddTeamResource(teamID, "energy", 1000000)
		end
	end
end

local function Upgrade(unitID, newTeam)
	if not dropZoneIDs[newTeam] then -- no dropzone left!
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_DROPZONE, {}, {}}, 1)
	elseif (teamUpgradeCounts[newTeam][C3_ID] + teamUpgradeCounts[newTeam][VPAD_ID]) % 2 == 0 then -- even number of upgrades get another C3
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_C3, {}, {}}, 1)
	else
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_VPAD, {}, {}}, 1)
	end
end

local function RunAndJump(unitID, unitDefID, cmdID, spotNum, replace)
	--Spring.Echo(UnitDefs[unitDefID].name .. [[ "Run And Jump!"]])
	if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then return end
	--Spring.Echo(UnitDefs[unitDefID].name .. [[ "Run And Jump is valid and alive!"]])
	cmdID = cmdID or CMD.MOVE
	local jumpDef = GG.jumpDefs[unitDefID]
	local jumpLength = Spring.GetUnitRulesParam(unitID, "jumpRange") or jumpDef.range
	local jumpReload = Spring.GetUnitRulesParam(unitID, "jumpReload") or jumpDef.reload

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
		--Spring.Echo("Adding CMD_MOVE")
		table.insert(orderArray, order)
		x = x + targetVector.x*jumpLength
		z = z + targetVector.z*jumpLength
		y = Spring.GetGroundHeight(x,z)
		--Spring.Echo("Adding CMD_JUMP")
		order = {y > 0 and CMD_JUMP or cmdID, {x, y, z}, {"shift"}}
		table.insert(orderArray, order)
	end
	-- make sure last command is a jump onto beacon
	order = {CMD_JUMP, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}
	table.insert(orderArray, order)
	--GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD_JUMP, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}, 1)
	GG.Delay.DelayCall(Spring.GiveOrderArrayToUnitArray, {{unitID}, orderArray}, 1)
end
GG.RunAndJump = RunAndJump

local function Wander(unitID, cmd)
	if Spring.ValidUnitID(unitID) then
		local spot = flagSpots[math.random(1, #flagSpots)]
		local offsetX = math.random(50, 150)
		local offsetZ = math.random(50, 150)
		offsetX = offsetX * -1 ^ (offsetX % 2)
		offsetZ = offsetZ * -1 ^ (offsetZ % 2)
		--GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.MOVE_STATE, {2}, {}}, 1)
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
		availablePerkCounts[unitID] = 0
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		for id, cmdDesc in pairs(cmdDescs) do
			if cmdDesc.action:find("perk") then
				availablePerks[unitID][id] = true
				availablePerkCounts[unitID] = availablePerkCounts[unitID] + 1
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

local WAIT_TIME = 45 * 30 -- 45s
local function UnitIdleCheck(unitID, unitDefID, teamID)
	if Spring.GetUnitIsDead(unitID) then return false end
	local cmdQueueSize = Spring.GetCommandQueue(unitID, -1, false) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo(UnitDefs[unitDefID].name .. [[ "I'm so not idle!"]]) 
		return
	end
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp.baseclass == "mech" then -- vehicles handled by unit_vehiclePad as they are always 'automated'
		-- random chance a idle unit will wander somewhere else
		--local chance = math.random(1, 100)
		--if chance < 75 then
			--Spring.Echo(UnitDefs[unitDefID].name .. [[ "Fuck it, I'm off for a wander"]])
			if cp.jumpjets then
				GG.Delay.DelayCall(RunAndJump, {unitID, unitDefID}, 1)
			else
				GG.Delay.DelayCall(Wander, {unitID}, 1)
			end
		--else
			--Spring.Echo(UnitDefs[unitDefID].name .. [[ "I think I'll stay here..."]])
		--end
	end
end

	
function gadget:UnitIdle(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, WAIT_TIME)
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
			--[[for k,v in pairs(Spring.GetTeamUnits(teamID)) do
				GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 10 * 30)
			end]]
		elseif unitDefID == VPAD_ID then
			teamUpgradeCounts[teamID][VPAD_ID] = teamUpgradeCounts[teamID][VPAD_ID] + 1
		elseif ud.canFly then
			--Spring.Echo("VTOL!")
			for _, spot in pairs(flagSpots) do
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.PATROL, {spot.x, 0, spot.z}, {"shift"}}, 30)
			end
		elseif cp.jumpjets then
			--Spring.Echo("JUMP MECH!")
			Perk(unitID, PERK_JUMP_RANGE, true)
			RunAndJump(unitID, unitDefID)
		elseif cp.baseclass == "mech" then
			--Spring.Echo("MECH!")
			Perk(unitID, nil, true)
			Wander(unitID)
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
		elseif UnitDefs[unitDefID].name:find("dropzone") then -- TODO: "DROPZONE_IDS[unitDefID] then" should work here
			dropZoneIDs[teamID] = nil
			-- TODO: why doesn't it get auto-switched like it does for player?
		end
	end
	if attackerTeam and AI_TEAMS[attackerTeam] then
		Spam(attackerTeam)
		if attackerID and (UnitDefs[attackerDefID].customParams.baseclass == "mech") then 
			Perk(attackerID) 
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if AI_TEAMS[newTeam] then
		if unitDefID == BEACON_ID then
			Upgrade(unitID, newTeam)
			Spam(newTeam)
		end
		if unitDefID == C3_ID or unitDefID == VPAD_ID then
			gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
			gadget:UnitUnloaded(unitID, unitDefID, newTeam)
		end
	end
end

--[[function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if AI_TEAMS[teamID] then
		if UnitDefs[unitDefID].customParams.baseclass == "mech" 
		and not (cmdOptions.shift or cmdOptions.alt)
		and (Spring.GetCommandQueue(unitID, -1, false) or 0) > 0 
		--and not cmdID == CMD.INSERT
		then
			Spring.Echo(UnitDefs[unitDefID].name, "Tried to replace a queue with ", cmdID, CMD[cmdID])
			--return false -- unit has a queue and this is trying to replace it
		end
	end
	return true
end]]

else
--	UNSYNCED
end
