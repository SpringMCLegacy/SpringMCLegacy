function gadget:GetInfo()
	return {
		name		= "Beacon Construction",
		desc		= "Controls beacons' construction abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/13",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
--SyncedRead

--SyncedCtrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint

-- Constants
local BEACON_ID = UnitDefNames["beacon"].id
local MIN_BUILD_RANGE = tonumber(UnitDefNames["beacon"].customParams.minbuildrange) or 230
local MAX_BUILD_RANGE = UnitDefNames["beacon"].buildDistance

-- Variables
local turretDefIDs = {} -- turretDefIDs[unitDefID] = true
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, ecm = 1, sensor = 1}
local turretOwners = {} -- turretOwners[turretID] = beaconID

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		if unitDef.name:find("turret") then
			turretDefIDs[unitDefID] = true
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == BEACON_ID then
		buildLimits[unitID] = {["turret"] = 4, ["ecm"] = 1, ["sensor"] = 1}
	elseif UnitDefs[unitDefID].name:find("turret") then -- TODO: Use a customparam here
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			turretOwners[unitID] = builderID
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	local turretOwnerID = turretOwners[unitID]
	if turretOwnerID then -- unit was a turret with owning beacon, open the slot back up
		buildLimits[turretOwnerID].turret = buildLimits[turretOwnerID].turret + 1
		for turretDefID in pairs(turretDefIDs) do
			EditUnitCmdDesc(turretOwnerID, FindUnitCmdDesc(turretOwnerID, -turretDefID), {disabled = false, params = {}})
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == BEACON_ID and cmdID < 0 then
		local tx, ty, tz = unpack(cmdParams)
		local dist = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
		if dist < MIN_BUILD_RANGE then
			Spring.Echo("Too close to beacon")
			return false
		elseif dist > MAX_BUILD_RANGE then
			Spring.Echo("Too far from beacon")
			return false
		end
		-- TODO: check which kind of structure it is and deduct accordingly
		if turretDefIDs[-cmdID] then -- Proposed unit is a turret
			local turretsRemaining = buildLimits[unitID].turret
			if turretsRemaining == 0 then 
				Spring.Echo("Turret limit reached")
				return false 
			else
				buildLimits[unitID].turret = turretsRemaining - 1
				if turretsRemaining == 1 then
					for turretDefID in pairs(turretDefIDs) do
						EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, -turretDefID), {disabled = true, params = {"L"}})
					end
				end
			end
		end
	end
	return true
end

else
--	UNSYNCED
end
