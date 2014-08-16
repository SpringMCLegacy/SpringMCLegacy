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
local BASE_DELAY = tonumber(modOptions and modOptions.vehicle_delay or "3") -- base line delay, may be +{0,10}s

local BEACON_ID = UnitDefNames["beacon"].id
local VPAD_ID = UnitDefNames["upgrade_vehiclepad"].id
--local DelayCall = GG.Delay.DelayCall
--local sides = {} -- teamID = is or clans

local flagSpots = {} --VFS.Include("maps/flagConfig/" .. Game.mapName .. "_profile.lua")

local vehiclesDefCache = {} -- unitDefID = true

local IS_VehicleDefs = {} -- IS_VehicleDefs[1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}
local C_VehicleDefs = {} -- C_VehicleDefs[1] = {unitDefID = unitDefID, squadSize = customParams.squadsize}

local teamVehicleDefs = {} -- e.g. vehicleDefs[teamID] = IS_VehicleDefs or C_VehicleDefs

local vehiclePads = {} -- uvehiclePads[unitID] = teamID

function gadget:Initialize()
	for unitDefID, unitDef in pairs(UnitDefs) do
		if unitDef.customParams.unittype == "vehicle" then
			vehiclesDefCache[unitDefID] = true
			local squadSize = unitDef.customParams.squadsize or 1
			if unitDef.name:sub(1,2) == "is" then -- Inner Sphere
				Spring.Echo("found a IS vehicle", unitDef.name)
				table.insert(IS_VehicleDefs, {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
			else -- clans
				table.insert(C_VehicleDefs, {["unitDefID"] = unitDefID, ["squadSize"] = squadSize})
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
		Spring.Echo(teamID, "side", side)
		teamVehicleDefs[teamID] = (side == "clans" and C_VehicleDefs) or IS_VehicleDefs
	end
end

local function RandomVehicle(teamID)
	return teamVehicleDefs[teamID][math.random(1, #teamVehicleDefs[teamID])]
end

local function Deliver(unitID, teamID)
	-- check VP didn't die or switch teams during delay
	if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) and teamID == Spring.GetUnitTeam(unitID) then
		local vehInfo = RandomVehicle(teamID)
		--Spring.Echo("Random vehicle:", UnitDefs[vehInfo.unitDefID].name, vehInfo.squadSize)
		GG.DropshipDelivery(unitID, teamID, "is_markvii", {{[vehInfo.unitDefID] = vehInfo.squadSize}}, 0, nil, 1) 
	end
end

function LCLeft(unitID, teamID) -- called by LC once it has left, to start countdown
	GG.Delay.DelayCall(Deliver, {unitID, teamID}, BASE_DELAY + math.random(10) * 30)
end
GG.LCLeft = LCLeft

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if unitDefID == BEACON_ID then
		local x,_,z = Spring.GetUnitPosition(unitID)
		table.insert(flagSpots, {x = x, z = z})
	end
	if unitDefID == VPAD_ID then
		-- TODO: add to list of spawning points
		vehiclePads[unitID] = teamID
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	-- TODO: remove from list to spawn at
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

--[[local function UnitIdleCheck(unitID, unitDefID, teamID)
	if Spring.GetUnitIsDead(unitID) then return false end
	local cmdQueueSize = Spring.GetCommandQueue(unitID, -1, false) or 0
	if cmdQueueSize > 0 then 
		--Spring.Echo("I'm so not idle!") 
		return
	end
	GG.Delay.DelayCall(Wander, {unitID}, 1)
end]]

	
function gadget:UnitIdle(unitID, unitDefID, teamID)
	if vehiclesDefCache[unitDefID] then -- a vehicle
		--GG.Delay.DelayCall(UnitIdleCheck, {unitID, unitDefID, teamID}, 10)
		GG.Delay.DelayCall(Wander, {unitID}, 1)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, teamID, transportID, transportTeam)
	if vehiclesDefCache[unitDefID] then -- a vehicle
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
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	-- TODO check if VPad is capped
	if unitDefID == VPAD_ID then
		GG.Delay.DelayCall(Deliver, {unitID, newTeam}, BASE_DELAY + math.random(10) * 30)
	end
end

else
--	UNSYNCED
end
