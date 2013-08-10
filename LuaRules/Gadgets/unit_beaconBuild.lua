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

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint

-- Constants
local BEACON_ID = UnitDefNames["beacon"].id
local MIN_BUILD_RANGE = tonumber(UnitDefNames["beacon"].customParams.minbuildrange) or 230
local MAX_BUILD_RANGE = UnitDefNames["beacon"].buildDistance
Spring.Echo(MAX_BUILD_RANGE)

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
	end
	return true
end

else
--	UNSYNCED
end
