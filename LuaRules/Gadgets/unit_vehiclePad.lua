function gadget:GetInfo()
	return {
		name		= "Vehicle Spawner",
		desc		= "AI Grunt Spawner",
		author		= "FLOZi (C. Lawrence)",
		date		= "16/08/14",
		license 	= "GNU GPL v2",
		layer		= 10,
		enabled	= true,	--	loaded by default?
	}
end



if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()
local BASE_DELAY = tonumber((modOptions and modOptions.vehicle_delay) or "15") * 30 -- base line delay, may be +{0,10}s
local BEACON_ID = UnitDefNames["beacon"].id
local VPAD_ID = UnitDefNames["upgrade_vehiclepad"].id
--local DelayCall = GG.Delay.DelayCall
--local sides = {} -- teamID = is or clans

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local vehiclesDefCache = {} -- unitDefID = true

local IS_VehicleDefs = {} -- IS_VehicleDefs["light"][1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}
local C_VehicleDefs = {} -- C_VehicleDefs["light"][1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}

local teamVehicleDefs = {} -- e.g. vehicleDefs[teamID] = IS_VehicleDefs or C_VehicleDefs

local vehiclePads = {} -- uvehiclePads[unitID] = unloadFrame

local unitSquads = {} -- unitSquads[unitID] = squadNum
local teamSquadCounts = {} -- teamSquadCounts[teamID] = numberOfSquads
local teamSquadSpots = {} -- teamSquadSpots[teamID][squadNum] = spotNum
local teamSquads = {}

function gadget:Initialize()
	for unitDefID, unitDef in pairs(UnitDefs) do
		if unitDef.customParams.unittype then
			local basicType = unitDef.customParams.unittype
			if basicType == "vehicle" or basicType == "apc" then
				vehiclesDefCache[unitDefID] = true
				local mass = unitDef.mass
				local weight = (basicType == "apc" and "apc") or (unitDef.canFly and "vtol") or GG.GetWeight(mass)
				local squadSize = unitDef.customParams.squadsize or 1
				if unitDef.name:sub(1,2) == "is" then -- Inner Sphere
					if not IS_VehicleDefs[weight] then IS_VehicleDefs[weight] = {} end
					table.insert(IS_VehicleDefs[weight], {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
				else -- clans
					if not C_VehicleDefs[weight] then C_VehicleDefs[weight] = {} end
					table.insert(C_VehicleDefs[weight], {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
				end
			end
		end
	end
	for _, teamID in pairs(Spring.GetTeamList()) do
		local side = select(5, Spring.GetTeamInfo(teamID)):lower()
		if (side == "") then
			-- startscript didn't specify a side for this team
			local sidedata = Spring.GetSideData()
			if (sidedata and #sidedata > 0) then
				local sideNum = 1 + teamID % #sidedata
				side = sidedata[sideNum].sideName:lower()
			end
		end
		--sides[teamID] = side
		teamVehicleDefs[teamID] = (side == "clans" and C_VehicleDefs) or IS_VehicleDefs
		teamSquadSpots[teamID] = {}
	end
end

local function RandomVehicle(teamID, weight)
	return teamVehicleDefs[teamID][weight][math.random(1, #teamVehicleDefs[teamID][weight])]
end

local MINUTE = 30 * 60
local function AgeWeight(age)
	local weight = "apc"
	-- make 10% infantry APC (well not quite)
	if math.random(100) < 10 then return weight end
	-- make 10% of all deliveries VTOL (well not quite)
	if math.random(100) < 10 then return "vtol" end
	-- 75% of the time, randomise the age so we don't always get the current max
	if math.random(100) < 100 then
		age = age * math.random()
	end
	if age < 2 * MINUTE then
		weight = "light"
	elseif age < 5 * MINUTE then
		weight = "medium"
	elseif age < 10 * MINUTE then
		weight = "heavy"
	else -- age > 10 * MINUTE
		weight = "assault"
	end
	return weight
end

local function Deliver(unitID, teamID)
	-- check VP didn't die or switch teams during delay
	if Spring.ValidUnitID(unitID) and (not Spring.GetUnitIsDead(unitID)) and (teamID == Spring.GetUnitTeam(unitID)) then
		local age = Spring.GetGameFrame() - vehiclePads[unitID]
		local vehInfo = RandomVehicle(teamID, AgeWeight(age))
		--Spring.Echo("Random vehicle:", UnitDefs[vehInfo.unitDefID].name, vehInfo.squadSize)
		GG.DropshipDelivery(unitID, teamID, "is_markvii", {{[vehInfo.unitDefID] = vehInfo.squadSize}}, 0, nil, 1) 
	end
end

function LCLeft(unitID, teamID) -- called by LC once it has left, to start countdown
	if Spring.ValidUnitID(unitID) and (not Spring.GetUnitIsDead(unitID)) and (teamID == Spring.GetUnitTeam(unitID)) then
		GG.Delay.DelayCall(Deliver, {unitID, teamID}, BASE_DELAY + math.random(10) * 30)
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
	unitSquads[cargoID] = teamSquadCounts[teamID]
end
GG.SetSquad = SetSquad

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if unitDefID == BEACON_ID then
		local x,_,z = Spring.GetUnitPosition(unitID)
		table.insert(flagSpots, {x = x, z = z})
	elseif unitDefID == VPAD_ID then
		-- for /give, UnitUnloaded will set it again in 'real' play
		vehiclePads[unitID] = Spring.GetGameFrame()	
	elseif unitDefID == UnitDefNames["is_markvii"].id then
		NewSquad(unitID, teamID)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	-- TODO: remove from list to spawn at
	unitSquads[unitID] = nil
end

local function Wander(unitID, cmd)
	if Spring.ValidUnitID(unitID) then
		local teamID = Spring.GetUnitTeam(unitID)
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
	if Spring.GetUnitIsDead(unitID) then return false end
	local cmdQueueSize = Spring.GetCommandQueue(unitID, 0) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo("UnitIdleCheck: I'm so not idle!") 
		return
	end
	local unitSquad = unitSquads[unitID]
	if not unitSquad then return end
	teamSquadSpots[teamID][unitSquad] = math.random(1, #flagSpots)
	GG.Delay.DelayCall(Wander, {unitID}, 1)
end


function gadget:UnitIdle(unitID, unitDefID, teamID)
	--Spring.Echo("UnitIdle", UnitDefs[unitDefID].name)
	if vehiclesDefCache[unitDefID] and not (Spring.GetUnitRulesParam(unitID, "dronesout") == 1) then -- a vehicle
		local commandQueue = Spring.GetCommandQueue(unitID)
		--for k, v in pairs(commandQueue) do Spring.Echo(k,v) end
		local cmdQueueSize = Spring.GetCommandQueue(unitID, 0) or 0
		if cmdQueueSize > 0 then 
			Spring.Echo("UnitIdle: I'm so not idle!") 
		end
		GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 1)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if vehiclesDefCache[unitDefID] then -- a vehicle
		SendToUnsynced("VEHICLE_UNLOADED", unitID, teamID)
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
		GG.Delay.DelayCall(Deliver, {unitID, newTeam}, BASE_DELAY + math.floor(math.random(1) * 30))
		vehiclePads[unitID] = Spring.GetGameFrame()
	end
end


else
--	UNSYNCED

function VehicleUnloaded(eventID, unitID, teamID)
	if teamID == Spring.GetMyTeamID() and not (GG.AI_TEAMS and GG.AI_TEAMS[teamID]) then
		--Spring.SetUnitNoSelect(unitID, true)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("VEHICLE_UNLOADED", VehicleUnloaded)
end


end
