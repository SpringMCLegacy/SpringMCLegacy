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
local TransferUnit			= Spring.TransferUnit
local SetUnitNeutral		= Spring.SetUnitNeutral

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local MIN_BUILD_RANGE = tonumber(UnitDefNames["beacon"].customParams.minbuildrange) or 230
local MAX_BUILD_RANGE = UnitDefNames["beacon"].buildDistance

-- Variables
local towerDefIDs = {} -- towerDefIDs[unitDefID] = "turret" or "ecm" or "sensor"
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, ecm = 1, sensor = 1}
local towerOwners = {} -- towerOwners[towerID] = beaconID

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local cp = unitDef.customParams
		if cp and cp.towertype then
			towerDefIDs[unitDefID] = cp.towertype
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == BEACON_ID then
		buildLimits[unitID] = {["turret"] = 4, ["ecm"] = 1, ["sensor"] = 1}
	elseif cp and cp.towertype then
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			towerOwners[unitID] = builderID
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	local towerOwnerID = towerOwners[unitID]
	if towerOwnerID then -- unit was a turret with owning beacon, open the slot back up
		buildLimits[towerOwnerID].turret = buildLimits[towerOwnerID].turret + 1
		for turretDefID in pairs(towerDefIDs) do
			EditUnitCmdDesc(towerOwnerID, FindUnitCmdDesc(towerOwnerID, -turretDefID), {disabled = false, params = {}})
		end
		towerOwners[unitID] = nil
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == BEACON_ID then
		for towerID, beaconID in pairs(towerOwners) do
			if beaconID == unitID then
				DelayCall(TransferUnit, {towerID, newTeam}, 1)
				local env = Spring.UnitScript.GetScriptEnv(towerID)
				Spring.UnitScript.CallAsUnit(towerID, env.TeamChange, newTeam)
				if newTeam == GAIA_TEAM_ID then
					SetUnitNeutral(towerID, true)
				else
					SetUnitNeutral(towerID, false)
				end
			end
		end
	end
end

function LimitTowerType(unitID, towerType)	
	local towersRemaining = buildLimits[unitID][towerType]
	if towersRemaining == 0 then 
		Spring.Echo("Limit reached for " .. towerType)
		return false 
	else
		buildLimits[unitID][towerType] = towersRemaining - 1
		if towersRemaining == 1 then
			for tDefID, tType in pairs(towerDefIDs) do
				if tType == towerType then
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, -tDefID), {disabled = true, params = {"L"}})
				end
			end
		end
		return true
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
		local towerType = towerDefIDs[-cmdID]
		if towerType then return LimitTowerType(unitID, towerType) end
	end
	return true
end

else
--	UNSYNCED
end
