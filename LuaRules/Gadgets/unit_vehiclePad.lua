function gadget:GetInfo()
	return {
		name		= "Vehicle Spawner",
		desc		= "AI Grunt Spawner",
		author		= "FLOZi (C. Lawrence)",
		date		= "16/08/14",
		license 	= "GNU GPL v2",
		layer		= 10, -- must be after game_spawn
		enabled	= true,	--	loaded by default?
	}
end



if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BASE_DELAY = tonumber((modOptions and modOptions.vehicle_delay) or "30") * 30 -- base line delay, may be +{0,10}s
local DEATH_DELAY = 60 * 30 -- delay next one by extra 1 minute if the last one died
local BEACON_ID = UnitDefNames["beacon"].id
local VPAD_ID = UnitDefNames["upgrade_vehiclepad"].id

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local vehiclesDefCache = {} -- unitDefID = squadSize -- ALL vehicles

local sideSpawnLists = {}

local vehiclePads = {} -- vehiclePads[unitID] = unloadFrame
local vehiclePadLevels = {} -- vehiclePadLevels[unitID] = 1, 2, 3 etc
local vehiclePadSides = {} -- vehiclePadSides[untiID] = "fs", etc

local unitSquads = {} -- unitSquads[unitID] = squadNum
local teamSquadCounts = {} -- teamSquadCounts[teamID] = numberOfSquads
local teamSquadSpots = {} -- teamSquadSpots[teamID][squadNum] = spotNum
local teamSquads = {}

local classes = {"vtol", "apc", "arty", "regular"}
local weights = {"light", "medium", "heavy", "assault",} -- TODO: this is repeated elsewhere

function gadget:Initialize()
	for sideName, shortName in pairs(GG.SideNames) do
		sideSpawnLists[shortName] = table.unserialize(UnitDefs[VPAD_ID].customParams.spawn)[shortName]
		--Spring.Echo(sideName)
		--table.echo(sideSpawnLists[shortName])
	end
	for unitDefID, unitDef in pairs(UnitDefs) do
		local basicType = unitDef.customParams.baseclass
		if basicType == "vehicle" or basicType == "vtol" then -- apc's are still vehicle but *identified* (not changed) in _post
			vehiclesDefCache[unitDefID] = 1 --unitDef.customParams.squadsize or 1
		end
	end
	for _, teamID in pairs(Spring.GetTeamList()) do
		if teamID ~= GAIA_TEAM_ID then
			teamSquadSpots[teamID] = {}
		end
	end
end

local levelDropships = {
	[1] = "is_markvii",
	[2] = "is_markvii",
	[3] = "is_drost",
}

local delays = {
	[1] = BASE_DELAY,
	[2] = BASE_DELAY * 1.2, -- 20% increase
	[3] = BASE_DELAY * 1.5, -- 50% increase
}

-- N.B. strictly speaking the probabilities for arty, vtol, apc are as follows (e.g. with level 3);
-- apc = 0.2, vtol = (1 - apc) * 0.2, arty = (1 - vtol) * 0.2
-- so 0.2, 0.16, 0.168. This could be corrected for but it would obfuscate the code,
-- and they are all 0.2 to 1sf anyway.

local chances = {
	[1] = { -- Tier 1: light/med
		-- following sum to 1
		class = {
			arty = 0.1,
			vtol = 0.1,
			apc = 0.1,
			regular = 0.7,
		},
		weights = {
			light = 0.5,
			medium = 0.5,
			heavy = 0,
			assault = 0,
		},
	},
	[2] = { -- Tier 2: heavy
		-- following sum to 1
		class = {
			arty = 0.1,
			vtol = 0.15,
			apc = 0.15,
			regular = 0.6
		},
		weights = {
			light = 0.0,
			medium = 0.5,
			heavy = 0.5,
			assault = 0.0,
		},
	},
	[3] = { -- Tier 3: assault
		-- following sum to 1
		class = {
			arty = 0.1,
			vtol = 0.2,
			apc = 0.2,
			regular = 0.5
		},
		weights = {
			light = 0.0,
			medium = 0.0,
			heavy = 0.5,
			assault = 0.5,
		},
	},
}

local function VPadUpgrade(unitID, level)
	-- level 1 -> Add Heavy units
	-- level 2 -> Add Assault units
	vehiclePadLevels[unitID] = level
	--Spring.Echo("Upgrade vehiclepad (" .. unitID .. ") to level " .. level)
	env = Spring.UnitScript.GetScriptEnv(unitID)
	Spring.UnitScript.CallAsUnit(unitID, env.Upgrade, level)
end
GG.VPadUpgrade = VPadUpgrade

local function RandomElement(input)
	return input[math.random(1, #input)]
end

local function RandomVehicle(unitID, level, class, weight, weightIndex)
	if not unitID then return false end 
	if Spring.GetUnitTeam(unitID) == GAIA_TEAM_ID then return false end -- team died
	
	local originalWeight = weight
	-- sideSpawnLists[side][level][class][weight]
	--Spring.Echo("Random Vehicle DESIRED", level, class, weight)
	while weightIndex > 0 and #sideSpawnLists[vehiclePadSides[unitID]][vehiclePadLevels[unitID]][class][weight] == 0 do
		weightIndex = weightIndex - 1
		weight = weights[weightIndex]
	end
	if weightIndex > 0 then -- we found a valid vehicle of this class in _some_ weight
		--Spring.Echo("Random Vehicle ACTUAL", level, class, weight)
		return RandomElement(sideSpawnLists[vehiclePadSides[unitID]][vehiclePadLevels[unitID]][class][weight])
	else -- can't find any vehicles of this class, try for a regular of the chosen weight
		if #sideSpawnLists[vehiclePadSides[unitID]][vehiclePadLevels[unitID]]["regular"][originalWeight] > 0 then
			--Spring.Echo("Random Vehicle ACTUAL", level, "regular (forced)", originalWeight)
			return RandomElement(sideSpawnLists[vehiclePadSides[unitID]][vehiclePadLevels[unitID]]["regular"][originalWeight])
		else -- no regular at this weight, give up and just send a light regular
			--Spring.Echo("Random Vehicle ACTUAL", level, "regular (forced)", "light (forced)")
			return RandomElement(sideSpawnLists[vehiclePadSides[unitID]][vehiclePadLevels[unitID]]["regular"]["light"])
		end
	end
end

local function ChooseElement(level, elementType, elementList)
	local chance = math.random()
	local cumulativeChance = 0
	
	for i, element in ipairs(elementList) do
		cumulativeChance = cumulativeChance + chances[level][elementType][element]
		if chance < cumulativeChance then
			return element, i
		end
	end
end
	


local function Deliver(unitID, teamID)
	-- check VP didn't die or switch teams during delay
	if Spring.ValidUnitID(unitID) and (not Spring.GetUnitIsDead(unitID)) and (teamID == Spring.GetUnitTeam(unitID)) then
		local age = Spring.GetGameFrame() - vehiclePads[unitID]
		local currLevel = vehiclePadLevels[unitID]
		local class = ChooseElement(currLevel, "class", classes)
		local weight, weightIndex = ChooseElement(currLevel, "weights", weights)
		local vehName = RandomVehicle(unitID, currLevel, class, weight, weightIndex)
		if vehName then
			--Spring.Echo("New Vehicle:", vehName, vehiclesDefCache[UnitDefNames[vehName].id], class, weight)
			GG.DropshipDelivery(Spring.GetUnitRulesParam(unitID, "beaconID"), unitID, teamID, levelDropships[currLevel], {{[vehName] = vehiclesDefCache[UnitDefNames[vehName].id]}}, 0, nil, 1) 
		else
			--Spring.Echo("No vehicle of that weight :(")
		end
	end
end

function LCLeft(beaconID, vPadID, teamID, died) -- called by LC once it has left, to start countdown
	if Spring.ValidUnitID(vPadID) and (not Spring.GetUnitIsDead(vPadID)) and (teamID == Spring.GetUnitTeam(vPadID)) then
		GG.Delay.DelayCall(Deliver, {vPadID, teamID}, (died and DEATH_DELAY or 0) + delays[vehiclePadLevels[vPadID]] + math.random(10) * 30)
	end
end
GG.LCLeft = LCLeft


local function NewSquad(unitID, teamID)
	local squadNum = (teamSquadCounts[teamID] or 0) + 1
	teamSquadCounts[teamID] = squadNum
	teamSquadSpots[teamID][squadNum] = math.random(1, #flagSpots)
	--Spring.Echo("SQUAD", squadNum, teamSquadSpots[teamID][squadNum])
end

local function SetSquad(cargoID, teamID)
	if vehiclesDefCache[Spring.GetUnitDefID(cargoID)] then
		unitSquads[cargoID] = teamSquadCounts[teamID]
	end
end
GG.SetSquad = SetSquad

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if unitDefID == BEACON_ID then
		local x,_,z = Spring.GetUnitPosition(unitID)
		table.insert(flagSpots, {x = x, z = z})
	elseif unitDefID == VPAD_ID then
		-- for /give, UnitUnloaded will set it again in 'real' play
		vehiclePads[unitID] = Spring.GetGameFrame()	
		vehiclePadLevels[unitID] = 1 -- default level
		vehiclePadSides[unitID] = GG.teamSide[teamID]
	elseif cp.dropship and cp.dropship == "vehicle" then
		NewSquad(unitID, teamID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	-- TODO: remove from list to spawn at
	unitSquads[unitID] = nil
	vehiclePads[unitID] = nil
	vehiclePadLevels[unitID] = nil
end

local function Wander(unitID, cmd)
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
		local teamID = Spring.GetUnitTeam(unitID)
		if select(3, Spring.GetTeamInfo(teamID)) then return false end -- team died
		if teamID == GAIA_TEAM_ID then return false end -- team died and unit transferred to gaia
		local spotNum = teamSquadSpots[teamID][unitSquads[unitID]] or math.random(1, #flagSpots)
		local spot = flagSpots[spotNum]
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

GG.Wander = Wander

local function UnitIdleCheck(unitID, unitDefID, teamID)
	if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) then return false end -- unit died
	if select(3, Spring.GetTeamInfo(teamID)) then return false end -- team died
	if teamID == GAIA_TEAM_ID then return false end -- team died and unit transferred to gaia
	local cmdQueueSize = Spring.GetCommandQueue(unitID, 0) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo("UnitIdleCheck: I'm so not idle!") 
		return
	end
	local unitSquad = unitSquads[unitID]
	if not unitSquad then return end
	teamSquadSpots[teamID][unitSquad] = math.random(1, #flagSpots)
	Wander(unitID)
end


function gadget:UnitIdle(unitID, unitDefID, teamID)
	--Spring.Echo("UnitIdle", UnitDefs[unitDefID].name)
	if vehiclesDefCache[unitDefID] and not (Spring.GetUnitRulesParam(unitID, "dronesout") == 1) then -- a vehicle
		--local commandQueue = Spring.GetCommandQueue(unitID)
		--for k, v in pairs(commandQueue) do Spring.Echo(k,v) end
		--local cmdQueueSize = Spring.GetCommandQueue(unitID, 0) or 0
		--if cmdQueueSize > 0 then 
			--Spring.Echo("UnitIdle: I'm so not idle!") 
		--end
		GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 1)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if vehiclesDefCache[unitDefID] then -- a vehicle
		SendToUnsynced("TOGGLE_SELECT", unitID, teamID, false)
		local ud = UnitDefs[unitDefID]
		if ud.canFly then
			--Spring.Echo("VTOL!")
			for _, spot in pairs(flagSpots) do
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.PATROL, {spot.x, 0, spot.z}, {"shift"}}, 30)
			end
		else
			--Spring.Echo("VEHICLE!")
			Wander(unitID)
		end
	elseif unitDefID == VPAD_ID then
		vehiclePads[unitID] = Spring.GetGameFrame()
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == VPAD_ID then
		GG.Delay.DelayCall(Deliver, {unitID, newTeam}, delays[vehiclePadLevels[unitID]] + math.floor(math.random(10) * 30))
		vehiclePads[unitID] = Spring.GetGameFrame()
	end
end


else
--	UNSYNCED

end
