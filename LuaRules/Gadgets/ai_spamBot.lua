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

local AI_OUTPOST_OPTIONS = {
	"OUTPOST_C3ARRAY",
	"OUTPOST_VEHICLEPAD",
	"OUTPOST_GARRISON",
	"OUTPOST_UPLINK",
	"OUTPOST_EWAR",
	"OUTPOST_MECHBAY",
}

local AI_OUTPOST_DEFS = {}
for i, name in pairs(AI_OUTPOST_OPTIONS) do
	AI_OUTPOST_DEFS[name] = UnitDefNames[name:lower()].id
end

--local DelayCall = GG.Delay.DelayCall
local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")

local PERK_JUMP_RANGE = GG.CustomCommands.GetCmdID("PERK_JUMP_EFFICIENCY")

local desired = {"CMD_SEND_ORDER", "CMD_DROPZONE", -- mech purchasing
				"CMD_DROPZONE_2", "CMD_DROPZONE_3", -- dropship upgrading
				"CMD_JUMP", "CMD_MASC", -- mech behaviour
				 "CMD_OUTPOST_C3ARRAY", "CMD_OUTPOST_VEHICLEPAD", "CMD_OUTPOST_EWAR", "CMD_OUTPOST_GARRISON", "CMD_OUTPOST_UPLINK", -- outposts (can already use)
				 "CMD_OUTPOST_MECHBAY", "CMD_OUTPOST_TURRETCONTROL", -- outposts (maybe soon)
				 "CMD_OUTPOST_SEISMIC", --"CMD_OUTPOST_SALVAGEYARD" -- outposts (not a priority)
				 }
local AI_CMDS = {}
for _, cmd in pairs(desired) do
	local cmdID, cost = GG.CustomCommands.GetCmdID(cmd)
	AI_CMDS[cmd] = {["id"] = cmdID, ["cost"] = cost}
end

local dropZoneIDs = {}
local orderSizes = {}

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local teamOutpostCounts = {} -- teamOutpostCounts[teamID] = {c3_id = 1, vpad_id = 1} etc
local teamOutpostIDs = {} -- teamOutpostIDs[teamID] = {unitDefID1 = {unit1 = true, ...}, ...}

local teamDropshipOutposts = {} -- teamDropshipOutposts[teamID] = 1
local teamBeacons = {} -- teamBeacons[teamID] = {beaconID1, beaconID2, ...}
local beaconOutpostCounts = {} -- beaconOutpostCounts[beaconID] = 3
local beaconIDs = {}

local teamMechCounts = {} -- teamMechCounts[myTeamID] = number

local function CostSort(unitDefID1, unitDefID2)
	return UnitDefs[unitDefID1].metalCost < UnitDefs[unitDefID2].metalCost
end

local function SimpleReverseSearch(sideTable, mCost, tCost)
	for i = #sideTable, 1, -1 do
		local unitDefID = sideTable[i]
		local foundMCost = UnitDefs[unitDefID].metalCost
		local foundTCost = UnitDefs[unitDefID].energyCost
		--Spring.Echo("I have " .. mCost .. "cbills and " .. tCost .. "tonnage.", UnitDefs[unitDefID].name .. " costs ", foundMCost, foundTCost)
		if foundMCost <= mCost and foundTCost <= tCost then return unitDefID end
	end
	return false -- no affordable mech!
end

local function TeamResourceChange(team, resource, change)
	
end
GG.AI = {}
GG.AI.TeamResourceChange = TeamResourceChange

local teamMechsNeedingBays = {}

local function MechNeedsBay(unitID, teamID)
	--Spring.Echo("Mech", unitID, "from team", teamID, "needs a mechbay")
	teamMechsNeedingBays[unitID] = true
	for mechbayID in pairs(teamOutpostIDs[teamID]["OUTPOST_MECHBAY"]) do
		--Spring.Echo("team", teamID, "totally has a mechbay is it empty?", Spring.GetUnitIsTransporting(mechbayID)[1])
		if not Spring.GetUnitIsTransporting(mechbayID)[1] then -- MechBay is currently empty 
		--TODO: of course this is not optimal as there may already be another mech on the way there, and a full one could be nearly done...
			-- we have a mechbay, send it there
			--Spring.Echo("team", teamID, "totally has an empty mechbay")
			local x,y,z = Spring.GetUnitPosition(mechbayID)
			Spring.GiveOrderToUnit(unitID, CMD.MOVE, {x,y,z}, {"alt"})
			Spring.GiveOrderToUnit(unitID, CMD.LOAD_ONTO, {mechbayID}, {"shift"})
			break
		end
	end
end

function gadget:Initialize()
	gadgetHandler:RegisterGlobal('MechNeedsBay', MechNeedsBay)
end

function gadget:GamePreload()
	-- Initialise unit limit for all AI teams.
	local name = gadget:GetInfo().name
	for _,t in ipairs(Spring.GetTeamList()) do
		teamOutpostIDs[t] = {}
		for _, name in pairs(AI_OUTPOST_OPTIONS) do
			teamOutpostIDs[t][name] = {}
		end
		teamOutpostCounts[t] = {}
		for name, id in pairs(AI_OUTPOST_DEFS) do
			teamOutpostCounts[t][id] = 0
		end
		if Spring.GetTeamLuaAI(t) ==  name then
			AI_TEAMS[t] = true
		end
		teamBeacons[t] = {}
		teamMechsNeedingBays[t] = {}
		teamMechCounts[t] = 0
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
		--Spring.Echo("Cheapest mech for " .. side .. " is " .. mechTable[1] .. " at " .. UnitDefs[mechTable[1]].metalCost)
	end
end

local function Outpost(beaconID, teamID)
	if not unitID then -- set as starting beacon if not given
		unitID = GG.dropZoneBeaconIDs[teamID]
	end
	if beaconOutpostCounts[beaconID] == 3 or not GG.beaconOutpostPointIDs[beaconID] then -- fully outposted or beacon's not deployed yet
		--Spring.Echo("Outpost 1 (return false, full count) BID:", beaconID, "TID:", teamID, beaconOutpostCounts[beaconID], GG.beaconOutpostPointIDs[beaconID])
		return false 
	end 
	if not dropZoneIDs[teamID] then -- no dropzone left!
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {beaconID, AI_CMDS["CMD_DROPZONE"].id, {}, {}}, 1)
		--Spring.Echo("Outpost 2 (DROPZONE) BID:", beaconID, "TID:", teamID, beaconOutpostCounts[beaconID], GG.beaconOutpostPointIDs[beaconID])
		return true
	elseif beaconID then -- gonna outpost a point, could still be nil if dropZoneBeaconIDs is behind the times
		--Spring.Echo("Outpost 3", unitID, teamID, beaconOutpostCounts[unitID], GG.beaconOutpostPointIDs[unitID])
		-- C3 if we have more mechs than capacity, otherwise try just randomly picking
		local randPick = teamMechCounts[teamID] > ((teamOutpostCounts[teamID][UnitDefNames["outpost_c3array"].id] + 1) * 4) and 1 or math.random(#AI_OUTPOST_OPTIONS)
		local cmd = "CMD_" .. AI_OUTPOST_OPTIONS[randPick]
		if difficulty > 1 then -- cheat the required resources in
			Spring.AddTeamResource(teamID, "metal", AI_CMDS[cmd].cost)
		end
		if Spring.GetTeamResources(teamID, "metal") > AI_CMDS[cmd].cost then
			-- outpostPointIDs[outpostID] = outpostPointID
			-- outpostIDs[outpostPointID] = outpostID
			-- need to check available slot rather than just picking...
			for slot, outpostPointID in pairs(GG.beaconOutpostPointIDs[beaconID]) do
				local currOutpost = GG.outpostIDs[outpostPointID]
				if not currOutpost then -- found free slot
					GG.Delay.DelayCall(Spring.GiveOrderToUnit, {outpostPointID, AI_CMDS[cmd].id, {}, {}}, 1)
					beaconOutpostCounts[beaconID] = (beaconOutpostCounts[beaconID] or 0) + 1
					--Spring.Echo("Outpost 4 (return true with cmd) BID:", beaconID, "TID:", teamID, beaconOutpostCounts[beaconID], GG.beaconOutpostPointIDs[beaconID], slot, cmd)
					return true
				end
			end
			--Spring.Echo("Outpost 5 (return false no free slot) BID:", beaconID, "TID:", teamID, beaconOutpostCounts[beaconID], GG.beaconOutpostPointIDs[beaconID])
			return false
		end
		--Spring.Echo("Outpost 6 (return false not enough c-bill) BID:", beaconID, "TID:", teamID, beaconOutpostCounts[beaconID], GG.beaconOutpostPointIDs[beaconID])
		return false
	end
	--Spring.Echo("Outpost 7 (nothing happened) BID:", beaconID, "TID:", teamID, beaconOutpostCounts[beaconID], GG.beaconOutpostPointIDs[beaconID])
end

local function SendOrder(teamID)
	local unitID = dropZoneIDs[teamID]
	local readyFrame = GG.dropZoneCoolDowns[teamID] or 0 --Spring.GetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN") or 0
	local frameDelay = math.max(readyFrame - Spring.GetGameFrame(), 0)
	if frameDelay == 0 and Spring.ValidUnitID(unitID) then
		orderSizes[teamID] = 0
		Spring.GiveOrderToUnit(unitID, AI_CMDS["CMD_SEND_ORDER"].id, {}, {})
	else
		--Spring.Echo("Can't SEND_ORDER until", readyFrame, "(", frameDelay, ")")
		GG.Delay.DelayCall(SendOrder, {teamID}, frameDelay + 30)
	end
end

local function Spam(teamID)
	--Spring.Echo("Spamming for team", teamID)
	local unitID = dropZoneIDs[teamID]
	if unitID and Spring.ValidUnitID(unitID) then
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		local side = GG.teamSide[teamID]
		orderSizes[teamID] = 0
		while orderSizes[teamID] < GG.TeamSlotsRemaining(teamID) do
			--Spring.Echo("COMPARING:", orderSizes[teamID], GG.TeamSlotsRemaining(teamID))
			local buildID
			if difficulty > 1 then
				Spring.AddTeamResource(teamID, "metal", 1500)
				if difficulty > 2 then
					Spring.AddTeamResource(teamID, "metal", 2500)
					if difficulty == 4 then -- Assaults only
						buildID = -sideAssaults[side][math.random(1, #sideAssaults[side])]
					elseif difficulty == 3 then -- jumpers only
						buildID = -sideJumpers[side][math.random(1, #sideJumpers[side])]
					end
					Spring.AddTeamResource(teamID, "energy", 100)
				else
					buildID = SimpleReverseSearch(sideMechs[side], 
							math.max(UnitDefs[sideMechs[side][1]].metalCost, 
							Spring.GetTeamResources(teamID, "metal") * math.random(5, 95)/100), 
							Spring.GetTeamResources(teamID, "energy"))
				end
			else
				--local cmdDesc = cmdDescs[math.random(1, #cmdDescs)]
				buildID = SimpleReverseSearch(sideMechs[side], 
						math.max(UnitDefs[sideMechs[side][1]].metalCost, 
						Spring.GetTeamResources(teamID, "metal") * math.random(5, 95)/100), 
						Spring.GetTeamResources(teamID, "energy"))
			end
			if buildID then
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, -buildID, {}, {}}, 1)
				orderSizes[teamID] = orderSizes[teamID] + 1
			--Spring.Echo("Adding to order;", orderSizes[teamID], UnitDefs[-buildID].name, GG.TeamSlotsRemaining(teamID))
			elseif orderSizes[teamID] == 0 then 
				-- couldn't find any affordable mechs, try upgrading 
				local beaconID = teamBeacons[teamID][math.random(#teamBeacons[teamID])]
				if not Outpost(beaconID, teamID) then
				
					-- outpost failed, try upgrading dropship
					local nextLevel = teamDropshipOutposts[teamID] + 1
					if nextLevel <= 3 then
						local cost = AI_CMDS["CMD_DROPZONE_" .. nextLevel].cost
						if difficulty > 1 then
							Spring.AddTeamResource(teamID, "metal", cost)
						end
						if Spring.GetTeamResources(teamID, "metal") > cost then
							GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, AI_CMDS["CMD_DROPZONE_" .. nextLevel].id, {}, {}}, 1)
							teamDropshipOutposts[teamID] = nextLevel
						end
					end
				end
				return
			end
		end
		GG.Delay.DelayCall(SendOrder, {teamID}, 2) -- frame after orders
	end
end

local availablePerks = {} -- availablePerks[unitID] = {cmdDescID = true, ...}
local availablePerkCounts = {} -- availablePerkCounts[unitID] = number

local function Perk(unitID, unitDefID, perkID, firstTime)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
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
	if cp.baseclass == "mech" and Spring.GetUnitExperience(unitID) < GG.PERK_XP_COST then
		return 
	end -- TODO: check for cost of c-bill outposts, its not in the cmdDesc, it's in the perkDef!
	local ID
	local count = availablePerkCounts[unitID]
	if not perkID and count and count > 0 then -- attempt to compare number with nil, via UnitDestroyed
		local cmdDescs = Spring.GetUnitCmdDescs(unitID)
		ID = math.random(1, #cmdDescs)
		while not (availablePerks[unitID][ID]) do
			ID = math.random(1, #cmdDescs)
		end
		perkID = cmdDescs[ID].id
	end
	if perkID and ID then
		availablePerks[unitID][ID] = false
		availablePerkCounts[unitID] = count - 1
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, perkID, {}, {}}, 1)
	end
end

local availableMods = {} -- availableMods[unitID] = {cmdDescID = true, ...}
local availableModsCounts = {} -- availableModsCounts[unitID] = number

-- TODO: generalise Perk instead of this copy paste job, complicated by the fact that mods are in bay menu but apply to mech
local function Mod(unitID, mechbayID, salvage)
	if not availableMods[unitID] then -- first time, setup
		availableMods[unitID] = {}
		availableModsCounts[unitID] = 0
		local cmdDescs = Spring.GetUnitCmdDescs(mechbayID)
		for id, cmdDesc in pairs(cmdDescs) do
			if cmdDesc.action:find("mod") then
				availableMods[unitID][id] = true
				availableModsCounts[unitID] = availableModsCounts[unitID] + 1
			end
		end
	end
	local modID, cost, ID
	if availableModsCounts[unitID] > 0 then
		--Spring.Echo("Available mods for", UnitDefs[Spring.GetUnitDefID(unitID)].name, availableModsCounts[unitID])
		local cmdDescs = Spring.GetUnitCmdDescs(mechbayID)
		local ID = math.random(1, #cmdDescs)
		while not (availablePerks[unitID][ID]) do
			ID = math.random(1, #cmdDescs)
			--Spring.Echo("I'm in a loop", ID)
		end
		modID = cmdDescs[ID].id
		--Spring.Echo("Mod selected for", UnitDefs[Spring.GetUnitDefID(unitID)].name, cmdDescs[ID].name)
	end	
	if modID and ID then -- TODO: lookup cost of mod, it's not in the cmdDesc but in the perkDef...
		availableMods[unitID][ID] = false
		availableModsCounts[unitID] = availableModsCounts[unitID] - 1
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {mechbayID, modID, {}, {}}, 1)
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	--if teamMechbayIDs[transportTeam][transportID] then
	if teamOutpostIDs[transportTeam]["OUTPOST_MECHBAY"][transportID] then
		Mod(unitID, transportID, GG.GetTeamSalvage(teamID))
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if unitDefID == BEACON_ID then
		local x,_,z = Spring.GetUnitPosition(unitID)
		table.insert(flagSpots, {x = x, z = z})
		table.insert(teamBeacons[teamID], unitID)
		beaconOutpostCounts[unitID] = 0
		beaconIDs[unitID] = teamID
	end
	if AI_TEAMS[teamID] then
		local unitDef = UnitDefs[unitDefID]
		if unitDef.name:find("dropzone") then
			dropZoneIDs[teamID] = unitID	
			Spam(teamID)
			Outpost(nil, teamID)
			Outpost(nil, teamID)
			Outpost(nil, teamID)
			teamDropshipOutposts[teamID] = 1
			GG.Delay.DelayCall(Outpost, {nil, teamID}, 1)
			if difficulty > 1 then -- loadsa money!
				Perk(unitID, unitDefID, nil, true)
			end
			--table.insert(teamOutpostIDs[teamID], unitID)
		elseif unitDef.customParams.baseclass == "mech" then
			local closeRange = WeaponDefs[unitDef.weapons[1].weaponDef].range * 0.7
			-- set engagement range to weapon 1 range
			Spring.SetUnitMaxRange(unitID, closeRange)
			teamMechCounts[teamID] = teamMechCounts[teamID] + 1
		elseif unitDef.customParams.baseclass == "outpost" then
			--table.insert(teamOutpostIDs[teamID], unitID)
			if difficulty > 1 then -- loadsa money!
				Perk(unitID, unitDefID, nil, true)
			end
		end
		if difficulty > 2 then -- harder AI tonnage cheats, needs storage to do so
			Spring.SetTeamResource(teamID, "es", 1000000)
			Spring.AddTeamResource(teamID, "energy", 1000000)
		end
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
		if y > 0 then
			local order = {cmdID, {x, y, z}, {replace and "" or "shift"}}
			--Spring.Echo("Adding CMD_MOVE")
			table.insert(orderArray, order)
		end
		x = x + targetVector.x*jumpLength
		z = z + targetVector.z*jumpLength
		y = Spring.GetGroundHeight(x,z)
		if y > 0 then
			--Spring.Echo("Adding CMD_JUMP")
			order = {y > 0 and AI_CMDS["CMD_JUMP"].id or cmdID, {x, y, z}, {"shift"}}
			table.insert(orderArray, order)
		end
	end
	-- make sure last command is a jump onto beacon
	order = {AI_CMDS["CMD_JUMP"].id, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}
	table.insert(orderArray, order)
	--GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, AI_CMDS["CMD_JUMP"].id, {target.x, Spring.GetGroundHeight(target.x, target.z), target.z}, {"shift"}}, 1)
	GG.Delay.DelayCall(Spring.GiveOrderArrayToUnitArray, {{unitID}, orderArray}, 1)
end
GG.RunAndJump = RunAndJump


local function GetSpotTarget(teamID, filter)
	local spot
	if teamID and filter then
		--Spring.Echo("GetSpotTarget1", teamID, filter)
		local enemyBeacons = {}
		for beaconID, beaconTeamID in pairs(beaconIDs) do
			--Spring.Echo("GST Loop", beaconID, beaconTeamID, teamID)
			if beaconTeamID ~= teamID then
				table.insert(enemyBeacons, beaconID)
			end
		end
		if #enemyBeacons > 0 then
			local targetID = enemyBeacons[math.random(1, #enemyBeacons)]
			--Spring.Echo("GetSpotTarget2", teamID, Spring.GetUnitTeam(targetID), filter, #enemyBeacons, targetID)
			return Spring.GetUnitPosition(targetID)
		end
	end
	-- any flag, ours or theirs
	spot = flagSpots[math.random(1, #flagSpots)]
	local offsetX = math.random(50, 150)
	local offsetZ = math.random(50, 150)
	offsetX = offsetX * -1 ^ (offsetX % 2)
	offsetZ = offsetZ * -1 ^ (offsetZ % 2)
	return spot.x + offsetX, 0, spot.z + offsetZ
end



local function GetUnitTarget(unitID, range)
	return Spring.GetUnitNearestEnemy(unitID, range or 9999999, true)
end

local function Wander(unitID, cmd)
	if Spring.ValidUnitID(unitID) then
		--GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.MOVE_STATE, {2}, {}}, 1)
		if cmd then
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmd, {GetSpotTarget(_, false)}, {}}, 1)
		end
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.FIGHT, {GetSpotTarget(_, false)}, {"shift"}}, 1)
	end
end

local function CallStrike(unitID, cmd, func, param1, param2)
	if Spring.ValidUnitID(unitID) then
		if Spring.GetUnitIsDead(unitID) then
			uplinkIDs[unitID] = nil
			return
		end
		-- TODO: track enemy units rather than just spamming at beacons
		-- in this case cmd should be passed
		--Spring.Echo("CallStrike", unitID, cmd, func, params)
		GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, cmd, {func(param1, param2)}, {}}, 1)
	end
end

-- TODO: properly lookup costs
local UPLINK_CMD_COSTS = {
	8000,
	16000,
	360000,
}

local function CleanTeamOutPosts(teamID, outpostName, unitID)
	if unitID then
		teamOutpostIDs[teamID][outpostName][unitID] = nil
	else -- delete all of them, should only be called if team died
		teamOutpostIDs[teamID][outpostName] = nil	
	end
end

local function UplinkCalls(teamID)
	if select(3, Spring.GetTeamInfo(teamID)) then -- Team is dead
		--CleanTeamOutPosts(teamID, "OUTPOST_UPLINK")
		return
	end
	local artyFrame = GG.artyCanFire[teamID]
	--Spring.Echo("UplinkCalls", teamID, artyFrame, GG.artyCanFire)
	if not artyFrame then return end -- don't bother going any further
	for unitID in pairs(teamOutpostIDs[teamID]["OUTPOST_UPLINK"]) do
		if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then -- Uplink is dead
			--CleanTeamOutPosts(teamID, "OUTPOST_UPLINK", unitID)
		else
			-- always try arty first as well as others
			local cBills = Spring.GetTeamResources(teamID, "metal")
			local randPick = math.random(GG.uplinkLevels[unitID]) 
			local artyCmdDesc = Spring.GetUnitCmdDescs(unitID, 1 + 8)[1]
			if difficulty > 1 then -- cheat the required resources in
				Spring.AddTeamResource(teamID, "metal", UPLINK_CMD_COSTS[1])
				Spring.AddTeamResource(teamID, "metal", UPLINK_CMD_COSTS[randPick])
			end
			if cBills > UPLINK_CMD_COSTS[1] then
				local currFrame = Spring.GetGameFrame()
				if artyFrame <= currFrame then
					CallStrike(unitID, artyCmdDesc.id, GetSpotTarget, teamID, true)
				else -- not ready yet, try again when it is ready
					GG.Delay.DelayCall(CallStrike, {unitID, artyCmdDesc.id, GetSpotTarget, teamID, true}, artyFrame - currFrame)
				end	
			end
			if randPick > 1 and cBills > UPLINK_CMD_COSTS[randPick] then
				local cmdDesc = Spring.GetUnitCmdDescs(unitID, randPick + 8)[1] -- skip irrelevant cmdDescs
				if cmdDesc.type == CMDTYPE.ICON_UNIT then
					CallStrike(unitID, cmdDesc.id, GetUnitTarget, unitID)
				else
					CallStrike(unitID, cmdDesc.id, GetSpotTarget, teamID, true)
				end
			end
		end
	end
end

local WAIT_TIME = 45 * 30 -- 45s
local function UnitIdleCheck(unitID, unitDefID, teamID)
	if Spring.GetUnitIsDead(unitID) or not Spring.ValidUnitID(unitID) then return false end
	local cmdQueueSize = (Spring.GetUnitCommandCount and Spring.GetUnitCommandCount(unitID)) or Spring.GetCommandQueue(unitID, 0) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo(UnitDefs[unitDefID].name .. [[ "I'm so not idle!"]]) 
		return
	end
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp.baseclass == "mech" then -- vehicles handled by unit_vehiclePad as they are always 'automated'
		local mechbayID = next(teamOutpostIDs[teamID]["OUTPOST_MECHBAY"])--teamMechbayIDs[teamID]) 
		if mechbayID and not Spring.GetUnitIsDead(mechbayID) and teamMechsNeedingBays[unitID] then -- in need of repair, go to a mechbay first
			Spring.GiveOrderToUnit(unitID, CMD.LOAD_ONTO, {mechbayID}, {"alt"})
		elseif cp.jumpjets then
			GG.Delay.DelayCall(RunAndJump, {unitID, unitDefID}, 1)
		else
			GG.Delay.DelayCall(Wander, {unitID, tonumber(cp.tonnage) <= 35 and CMD.MOVE}, 1)
		end
	end
end

	
function gadget:UnitIdle(unitID, unitDefID, teamID)
	if AI_TEAMS[teamID] then
		GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, WAIT_TIME)
	end
end

local OUTPOST_FUNCTION_ALIASES = {
	[AI_OUTPOST_DEFS["OUTPOST_UPLINK"]] = UplinkCalls,
	[AI_OUTPOST_DEFS["OUTPOST_C3ARRAY"]] = Spam,
}

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if AI_TEAMS[teamID] then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		if AI_OUTPOST_DEFS[ud.name:upper()] then
			--Spring.Echo("team", teamID, "deployed a", ud.name)
			teamOutpostCounts[teamID][unitDefID] = teamOutpostCounts[teamID][unitDefID] + 1
			-- TODO: really this should be updated here, but creates an even worse race condition than having it upon ordering
			--[[local beaconID = Spring.GetUnitRulesParam(unitID, "beaconID")
			if beaconID then
				beaconOutpostCounts[beaconID] = beaconOutpostCounts[beaconID] + 1
			end]]
			local func = OUTPOST_FUNCTION_ALIASES[unitDefID]
			if func then -- the  Outpost should trigger a function
				GG.Delay.DelayCall(func, {teamID}, 10 * 30)
			end
			for _, name in pairs(AI_OUTPOST_OPTIONS) do
				if unitDefID == AI_OUTPOST_DEFS[name] then	
					teamOutpostIDs[teamID][name][unitID] = true	
				end
			end
			Perk(unitID, unitDefID, nil, true)
		elseif cp.jumpjets then
			--Spring.Echo("JUMP MECH!")
			Perk(unitID, unitDefID, PERK_JUMP_RANGE, true)
			RunAndJump(unitID, unitDefID)
		elseif cp.baseclass == "mech" then
			--Spring.Echo("MECH!")
			Perk(unitID, unitDefID, nil, true)
			Wander(unitID, tonumber(cp.tonnage) <= 35 and CMD.MOVE)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if AI_TEAMS[teamID] then
	
		local beaconID = Spring.GetUnitRulesParam(unitID, "beaconID") -- not cleared until 5 frames later by game_outposts
		if UnitDefs[unitDefID].customParams.baseclass == "outpost" and beaconID then
			teamOutpostCounts[teamID][unitDefID] = teamOutpostCounts[teamID][unitDefID] - 1
			beaconOutpostCounts[beaconID] = beaconOutpostCounts[beaconID] - 1
			--Spring.Echo("UnitDestroyed outpost died BID:", beaconID, "TID:", teamID, UnitDefs[unitDefID].name, "new beacon outpost count", beaconOutpostCounts[beaconID])
			-- Just set all these to nil regardless of which it was
			for _, name in pairs(AI_OUTPOST_OPTIONS) do
				teamOutpostIDs[teamID][name][unitID] = nil
			end
			-- try building a new outpost
			Outpost(beaconID, teamID)
		elseif UnitDefs[unitDefID].name:find("dropzone") then -- TODO: "DROPZONE_IDS[unitDefID] then" should work here
			dropZoneIDs[teamID] = nil
			-- TODO: why doesn't it get auto-switched like it does for player? Presume it is a widget so isn't executed as unsynced?
			local newBaseBeacon = next(teamBeacons[teamID])
			if newBaseBeacon and Spring.ValidUnitID(newBaseBeacon) then
				Spring.GiveOrderToUnit(newBaseBeacon, GG.CustomCommands.GetCmdID("CMD_DROPZONE"))
			end
		elseif UnitDefs[unitDefID].customParams.baseclass == "mech" then
			teamMechCounts[teamID] = teamMechCounts[teamID] - 1
			Spam(teamID)
		end
	end
	if attackerTeam and AI_TEAMS[attackerTeam] then
		--Spam(attackerTeam)
		if attackerID and not Spring.GetUnitIsDead(attackerID) and (UnitDefs[attackerDefID].customParams.baseclass == "mech") then 
			Perk(attackerID, attackerDefID) 
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if AI_TEAMS[newTeam] then
		if unitDefID == BEACON_ID then
			beaconIDs[unitID] = newTeam
			table.insert(teamBeacons[newTeam], unitID)
			beaconOutpostCounts[unitID] = 0
			-- TODO: not sure if I need to be so careful here or can remove during the loop?
			local toRemove = 0
			for i, beaconID in ipairs(teamBeacons[oldTeam]) do
				if beaconID == unitID then
					toRemove = i
				end
			end
			if toRemove > 0 then
				table.remove(teamBeacons[oldTeam], i)
			end
			Outpost(unitID, newTeam)
			--Outpost(unitID, newTeam)
			--Outpost(unitID, newTeam)
			Spam(newTeam)
		end
		if UnitDefs[unitDefID].customParams.baseclass == "outpost" then
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

function gadget:GameFrame(n)
	if n % (30 * 60) == 0 then -- once a minute
		for teamID in pairs(AI_TEAMS) do
			if not select(3, Spring.GetTeamInfo(teamID)) then -- not dead
				-- try and buy new mechs
				Spam(teamID)
				-- try and order artillery strikes
				UplinkCalls(teamID)
				-- try and outpost any beacons
				for i, unitID in pairs(teamBeacons[teamID]) do
					Outpost(unitID, teamID)
				end
				-- try and upgrade any existing outposts
				for _, name in pairs(AI_OUTPOST_OPTIONS) do
					for i, unitID in pairs(teamOutpostIDs[teamID][name]) do
						Perk(unitID, AI_OUTPOST_DEFS[name])
					end
				end
			end
		end
	end
end

else
--	UNSYNCED
end
