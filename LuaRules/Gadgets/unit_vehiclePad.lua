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
--local DelayCall = GG.Delay.DelayCall
--local sides = {} -- teamID = is or clans

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local vehiclesDefCache = {} -- unitDefID = true -- ALL vehicles

local sideVehicleDefs = {} -- sideVehicleDefs[side]["light"][1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}
local sideArtyDefs = {} -- sideArtyDefs[side]["light"][1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}
local sideAPCDefs = {} -- sideAPCDefs[side]["apc"][1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}

local teamVehicleDefs = {} -- e.g. teamVehicleDefs[teamID] = SIDE_VehicleDefs
local teamArtyDefs = {} -- e.g. teamArtyDefs[teamID] = SIDE_ArtyDefs
local teamAPCDefs = {} -- e.g. teamAPCDefs[teamID] = SIDE_ArtyDefs

local vehiclePads = {} -- uvehiclePads[unitID] = unloadFrame

local unitSquads = {} -- unitSquads[unitID] = squadNum
local teamSquadCounts = {} -- teamSquadCounts[teamID] = numberOfSquads
local teamSquadSpots = {} -- teamSquadSpots[teamID][squadNum] = spotNum
local teamSquads = {}
local weights = {"light", "medium", "heavy", "assault",} -- TODO: this is repeated elsewhere

function gadget:Initialize()
	for sideName, shortName in pairs(GG.SideNames) do
		sideVehicleDefs[shortName] = {}
		sideArtyDefs[shortName] = {}
		sideAPCDefs[shortName] = {}
		for i, weight in pairs(weights) do
			sideVehicleDefs[shortName][weight] = {}
			sideArtyDefs[shortName][weight] = {}
		end
		sideAPCDefs[shortName]["apc"] = {}
	end
	for unitDefID, unitDef in pairs(UnitDefs) do
		local basicType = unitDef.customParams.baseclass
		if basicType == "vehicle" then
			vehiclesDefCache[unitDefID] = true
			local mass = unitDef.mass
			local weight = unitDef.transportCapacity > 0 and "apc" or GG.GetWeight(mass)
			local squadSize = unitDef.customParams.squadsize or 1
			local side = unitDef.name:sub(1,2)
			if GG.ValidSides[side] then
				if weight == "apc" then
					table.insert(sideAPCDefs[side][weight], {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
				elseif unitDef.customParams.artillery then
					table.insert(sideArtyDefs[side][weight], {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
				else
					table.insert(sideVehicleDefs[side][weight], {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
				end
				--Spring.Echo("INSERTIN", unitDef.name, side, weight)
			end
		end
	end
	for _, teamID in pairs(Spring.GetTeamList()) do
		if teamID ~= GAIA_TEAM_ID then
			local side = GG.teamSide[teamID]
			teamVehicleDefs[teamID] = sideVehicleDefs[side]
			teamArtyDefs[teamID] = sideArtyDefs[side]
			teamAPCDefs[teamID] = sideAPCDefs[side]
			teamSquadSpots[teamID] = {}
		end
	end
end

local MINUTE = 30 * 60
local LIGHT = 2 * MINUTE -- up to 2 min, only lights
local MEDIUM = 5 * MINUTE -- from 2-5 min, medium or light
local HEAVY = 10 * MINUTE -- 5-10 min, heavy, medium or light
-- 10min+, assault, heavy, medium or light

local L1 = 25 --10
local L2 = L1 + 25 -- 15
local L3 = L2 + 25 -- 20

local ARTY_CHANCE = 0.10 -- 10%
local APC_CHANCE = 0.10 -- 10%

local function RandomElement(flavour, teamID, weight)
	return flavour[teamID][weight][math.random(1, #flavour[teamID][weight])]
end

local function RandomVehicle(teamID, weight)
	if not teamID or select(3, Spring.GetTeamInfo(teamID)) then return false end -- team died
	if teamID == GAIA_TEAM_ID then return false end
	if (math.random() <= APC_CHANCE) and (#teamAPCDefs[teamID]["apc"] > 0) then
		--Spring.Echo("OMG you rolled APC!")
		return RandomElement(teamAPCDefs, teamID, "apc")
	elseif (math.random() <= ARTY_CHANCE) and (#teamArtyDefs[teamID][weight] > 0) then
		--Spring.Echo("OMG you rolled arty!", weight)
		return RandomElement(teamArtyDefs, teamID, weight)
	elseif #teamVehicleDefs[teamID][weight] > 0 then -- return a regular vehicle
		--Spring.Echo("OMG you rolled ready salted!", weight)
		return RandomElement(teamVehicleDefs, teamID, weight)
	else
		--Spring.Echo("OMG this faction has none of those!", weight)
		return false -- This faction does not have a vehicle in that weight category
	end
end

local function AgeWeight(age)
	local topLevel = (age < LIGHT and 1) or (age < MEDIUM and 2) or (age < HEAVY and 3) or 4 -- age >= ASSAULT
	--Spring.Echo("Best Available: ", weights[topLevel])
	local chance = math.random(100)
	if chance < L1 then 	-- 10% of time return best
		return weights[topLevel]
	elseif chance < L2 then -- 15% of time return 2nd best
		return weights[math.max(1, topLevel - 1)]
	elseif chance < L3 then -- 20% of the time return 3rd best
		return weights[math.max(1, topLevel - 2)]
	else                    -- 55% of the time return the worst
		return weights[1]
	end
end

local function Deliver(unitID, teamID)
	-- check VP didn't die or switch teams during delay
	if Spring.ValidUnitID(unitID) and (not Spring.GetUnitIsDead(unitID)) and (teamID == Spring.GetUnitTeam(unitID)) then
		local age = Spring.GetGameFrame() - vehiclePads[unitID]
		local ageWeight = AgeWeight(age)
		local vehInfo = RandomVehicle(teamID, ageWeight)
		if vehInfo then
			--Spring.Echo("New Vehicle:", UnitDefs[vehInfo.unitDefID].name, vehInfo.squadSize, ageWeight)
			GG.DropshipDelivery(unitID, teamID, "is_drost", {{[vehInfo.unitDefID] = vehInfo.squadSize}}, 0, nil, 1) 
		else
			--Spring.Echo("No vehicle of that weight :(")
		end
	end
end

function LCLeft(unitID, teamID, died) -- called by LC once it has left, to start countdown
	if Spring.ValidUnitID(unitID) and (not Spring.GetUnitIsDead(unitID)) and (teamID == Spring.GetUnitTeam(unitID)) then
		GG.Delay.DelayCall(Deliver, {unitID, teamID}, (died and DEATH_DELAY or 0) + BASE_DELAY + math.random(10) * 30)
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
	if unitDefID == BEACON_ID then
		local x,_,z = Spring.GetUnitPosition(unitID)
		table.insert(flagSpots, {x = x, z = z})
	elseif unitDefID == VPAD_ID then
		-- for /give, UnitUnloaded will set it again in 'real' play
		vehiclePads[unitID] = Spring.GetGameFrame()	
	elseif unitDefID == UnitDefNames["is_drost"].id then
		NewSquad(unitID, teamID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	-- TODO: remove from list to spawn at
	unitSquads[unitID] = nil
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
	--GG.Delay.DelayCall(Wander, {unitID}, 1)
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
		-- TODO: add to list of spawning points
		vehiclePads[unitID] = Spring.GetGameFrame()
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	-- TODO check if VPad is capped
	if unitDefID == VPAD_ID then
		GG.Delay.DelayCall(Deliver, {unitID, newTeam}, BASE_DELAY + math.floor(math.random(10) * 30))
		vehiclePads[unitID] = Spring.GetGameFrame()
	end
end


else
--	UNSYNCED

end
