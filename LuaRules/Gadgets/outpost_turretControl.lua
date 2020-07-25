function gadget:GetInfo()
	return {
		name		= "Outpost - AI Turret COntrol",
		desc		= "Controls beacons' construction abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "24/07/20",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
--SyncedCtrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local SetUnitNeutral		= Spring.SetUnitNeutral

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local TURRETCONTROL_ID = UnitDefNames["outpost_turretcontrol"].id
local MAX_BUILD_RANGE = UnitDefs[TURRETCONTROL_ID].buildDistance

-- Variables
local towerDefIDs = {} -- towerDefIDs[unitDefID] = "turret" or "energy" or "ranged"
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, ...}
local towerOwners = {} -- towerOwners[towerID] = outpostID
local ownedTowers = {} -- ownedTowers[outpostID] = {towerID = true, ...}


function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		-- automatically build table of towers
		if cp and cp.baseclass == "tower" and not name:find("garrison") then -- TODO: remove the old garrison turret unitdefs
			towerDefIDs[unitDefID] = cp.turrettype or "turret"
		end
	end
end

-- TOWERS
function LimitTowerType(unitID, teamID, towerType, increase)	
	local towersRemaining = buildLimits[unitID][towerType]
	if increase then
		buildLimits[unitID][towerType] = towersRemaining + increase
		for tDefID, tType in pairs(towerDefIDs) do
			if tType == towerType then
				local cmdDescID = FindUnitCmdDesc(unitID, -tDefID)
				if cmdDescID then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = {}})
				end
			end
		end
	elseif towersRemaining == 0 then 
		Spring.SendMessageToTeam(teamID, "Limit reached for " .. towerType)
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
GG.LimitTowerType = LimitTowerType -- for outpost_turretcontrol perk

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == TURRETCONTROL_ID then
		buildLimits[unitID] = {["turret"] = 2, ["energy"] = 1, ["ranged"] = 1}
		ownedTowers[unitID] = {}
		LimitTowerType(unitID, teamID, "energy") -- reduce to 0 so we get the BP greyed out
		LimitTowerType(unitID, teamID, "ranged") -- reduce to 0 so we get the BP greyed out
	elseif cp and cp.baseclass == "tower" then
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			towerOwners[unitID] = builderID
			ownedTowers[builderID][unitID] = true
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	local towerOwnerID = towerOwners[unitID]
	if towerOwnerID then -- unit was a turret with owning beacon, open the slot back up
		local towerType = towerDefIDs[unitDefID]
		LimitTowerType(towerOwnerID, teamID, towerType, 1) -- increase limit
		towerOwners[unitID] = nil
		if ownedTowers[towerOwnerID] then -- can be nil if control died, as this does not delete towerOwners
			ownedTowers[towerOwnerID][unitID] = nil
		end
	elseif unitDefID == TURRETCONTROL_ID then -- turret control died, kill link and disable
		for towerID in pairs(ownedTowers[unitID]) do
			GG.ToggleLink(towerID, teamID, true)
			local env = Spring.UnitScript.GetScriptEnv(towerID)
			Spring.UnitScript.CallAsUnit(towerID, env.TeamChange, GAIA_TEAM_ID) -- toggle firing
		end
		ownedTowers[unitID] = nil
	end
end


function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if unitDefID == TURRETCONTROL_ID then
		for towerID, beaconID in pairs(towerOwners) do
			if beaconID == unitID then
				DelayCall(TransferUnit, {towerID, newTeam}, 1)
				local env = Spring.UnitScript.GetScriptEnv(towerID)
				Spring.UnitScript.CallAsUnit(towerID, env.TeamChange, newTeam)
				DelayCall(SetUnitNeutral,{towerID, newTeam == GAIA_TEAM_ID}, 2)
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == TURRETCONTROL_ID then
		if cmdID < 0 then
			local towerType = towerDefIDs[-cmdID]
			if not towerType then return false end
			if unitDefID == TURRETCONTROL_ID then -- TurretControl has limited build radius -- TODO: within the beacon
				local tx, ty, tz = unpack(cmdParams)
				local dist = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
				-- check for max range, although limited via unit script to only build inside beacon radius... 
				-- ...need to ensure it is within the beacon radius we are built at!
				if dist > MAX_BUILD_RANGE then
					Spring.SendMessageToTeam(teamID, "Too far from Turret Control!")
					return false
				end
			end
			return LimitTowerType(unitID, teamID, towerType)
		end
	elseif UnitDefs[unitDefID].customParams.decal then
		return false -- disallow all commands to decals
	end
	return true
end

function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

end
