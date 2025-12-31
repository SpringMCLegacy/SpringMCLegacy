function gadget:GetInfo()
	return {
		name		= "Outpost - AI Turret Control",
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
-- SyncedRead
local GetTeamResources 		= Spring.GetTeamResources
local GetUnitIsDead			= Spring.GetUnitIsDead
local GetUnitRulesParam		= Spring.GetUnitRulesParam
local GetUnitsInCylinder	= Spring.GetUnitsInCylinder
local ValidUnitID 			= Spring.ValidUnitID

--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local SetUnitNeutral		= Spring.SetUnitNeutral
local SetSquareBuildingMask = Spring.SetSquareBuildingMask

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local TURRETCONTROL_ID = UnitDefNames["outpost_turretcontrol"].id
local MAX_BUILD_RANGE = UnitDefs[TURRETCONTROL_ID].buildDistance

-- Variables
local towerDefIDs = {} -- towerDefIDs[unitDefID] = "turret" or "energy" or "ranged"
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, ...}
local towerOwners = {} -- towerOwners[towerID] = outpostID
local ownedLimits = {} -- ownedLimits[outpostID] = {type = number, ...}


-- Called by the outpost.lua script for the beacon it is associated with
function BuildMaskCircle(cx, cz, r, mask)
	local r2 = r * r
	local step = Game.squareSize * 2
	for z = 0, 2 * r, step do -- top to bottom diameter
		local lineLength = math.sqrt(r2 - (r - z) ^ 2)
		for x = -lineLength, lineLength, step do
			local squareX, squareZ = (cx + x)/step, (cz + z - r)/step
			if squareX > 0 and squareZ > 0 and squareX < Game.mapSizeX/step and squareZ < Game.mapSizeZ/step then
				SetSquareBuildingMask(squareX, squareZ, mask)
				--Spring.MarkerAddPoint((cx + x), 0, (cz + z - r))
			end
		end
	end	
end
GG.BuildMaskCircle = BuildMaskCircle

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		-- automatically build table of towers
		if cp and cp.baseclass == "turret" and not name:find("garrison") then -- TODO: remove the old garrison turret unitdefs
			towerDefIDs[unitDefID] = cp.turrettype or "turret"
		end
	end
end

-- TOWERS
function LimitTowerType(unitID, teamID, towerType, increase)	
	if not unitID or unitID and Spring.GetUnitIsDead(unitID) then return false end
	local towersRemaining = buildLimits[unitID][towerType]
	--Spring.Echo("LimitTowerType", towerType, increase, ownedLimits[unitID][towerType], towersRemaining) -- 1,1,0
	if increase then -- giving slots back
		buildLimits[unitID][towerType] = towersRemaining + increase
		for tDefID, tType in pairs(towerDefIDs) do
			if tType == towerType then
				local cmdDescID = FindUnitCmdDesc(unitID, -tDefID)
				if cmdDescID then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = {}})
				end
			end
		end
		local x, _, z = Spring.GetUnitPosition(unitID)
		LinkCheck(x, z, unitID, teamID) -- check if this allows to control any link lost
	elseif towersRemaining == 0 then 
		Spring.SendMessageToTeam(teamID, "Limit reached for " .. towerType)
		return false 
	else -- we have the slots
		buildLimits[unitID][towerType] = towersRemaining - 1
		if towersRemaining == 1 then
			for tDefID, tType in pairs(towerDefIDs) do
				local place = FindUnitCmdDesc(unitID, -tDefID)
				if place and tType == towerType then
					EditUnitCmdDesc(unitID, place, {disabled = true, params = {"L"}})
				end
			end
		end
		ownedLimits[unitID][towerType] = ownedLimits[unitID][towerType] + 1
		--Spring.Echo("Added tower", towerType, ownedLimits[unitID][towerType])
		return true
	end
end
GG.LimitTowerType = LimitTowerType -- for outpost_turretcontrol perk

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == TURRETCONTROL_ID then
		-- Remove all faction turrets that do not belong to the team's side
		local side = GG.teamSide[teamID]
		if not side then return end -- presume team is dead
		local toDelete = {}
		for i, cmdDesc in pairs(Spring.GetUnitCmdDescs(unitID)) do
			if cmdDesc.id < 0 then
				local turretDef = UnitDefs[-cmdDesc.id]
				local faction = turretDef and turretDef.customParams.faction
				if faction and faction ~= side then
					toDelete[cmdDesc.id] = true
				end
			end
		end
		for cmdID in pairs(toDelete) do
			Spring.RemoveUnitCmdDesc(unitID, Spring.FindUnitCmdDesc(unitID, cmdID))
		end
		buildLimits[unitID] = {["turret"] = 2, ["energy"] = 1, ["ranged"] = 1}
		ownedLimits[unitID] = {["turret"] = 0, ["energy"] = -1, ["ranged"] = -1}
		LimitTowerType(unitID, teamID, "energy") -- reduce to 0 so we get the BP greyed out
		LimitTowerType(unitID, teamID, "ranged") -- reduce to 0 so we get the BP greyed out
	elseif cp and cp.baseclass == "tower" then
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			towerOwners[unitID] = builderID
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	local towerOwnerID = towerOwners[unitID]
	if towerOwnerID then -- unit was a turret with owning beacon, open the slot back up
		local towerType = towerDefIDs[unitDefID]
		towerOwners[unitID] = nil
		if ValidUnitID(towerOwnerID) and not GetUnitIsDead(towerOwnerID) then
			if ownedLimits[towerOwnerID] then -- can be nil if control died, as this does not delete towerOwners
				ownedLimits[towerOwnerID][towerType] = ownedLimits[towerOwnerID][towerType] - 1
			end
			LimitTowerType(towerOwnerID, teamID, towerType, 1) -- increase limit
		end
	elseif unitDefID == TURRETCONTROL_ID then -- turret control died, kill link and disable
		for towerID, controllerID in pairs(towerOwners) do
			if controllerID == unitID then
				GG.ToggleLink(towerID, teamID, true)
				local env = Spring.UnitScript.GetScriptEnv(towerID)
				Spring.UnitScript.CallAsUnit(towerID, env.TeamChange, GAIA_TEAM_ID) -- toggle firing
				DelayCall(TransferUnit, {towerID, GAIA_TEAM_ID}, 1)
				DelayCall(SetUnitNeutral,{towerID, true}, 1)
			end
		end
		ownedLimits[unitID] = nil
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == TURRETCONTROL_ID then
		if cmdID < 0 then
			local towerType = towerDefIDs[-cmdID]
			if not towerType then return false end
			
			local tx, ty, tz = unpack(cmdParams)
			local dist = GG.GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
			-- check for max range, although limited via unit script to only build inside beacon radius... 
			-- ...need to ensure it is within the beacon radius we are built at!
			if dist > MAX_BUILD_RANGE then
				Spring.SendMessageToTeam(teamID, "Too far from Turret Control!")
				GG.PlaySoundForTeam(teamID, "bb_turret_toofar", 1)
			-- check we have the resources
			elseif GetTeamResources(teamID, "metal") < UnitDefs[-cmdID].metalCost then
				GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
				Spring.SendMessageToTeam(teamID, "Not enough C-Bills for tower deployment!")	
			end
			-- check we have the slots
			if LimitTowerType(unitID, teamID, towerType) then
				local success = CreateUnit(-cmdID, tx, ty, tz, 1, teamID, false, false, nil, unitID)
				--Spring.Echo("Yo make a turret!", -cmdID, UnitDefs[-cmdID].name, success)
			end
			return false -- don't let the engine build it itself whether we passed the conditions or not
		end
	elseif UnitDefs[unitDefID].customParams.decal then
		return false -- disallow all commands to decals
	end
	return true
end


function gadget:UnitGiven(unitID, unitDefID, teamID, oldTeamID)
	if oldTeamID == GAIA_TEAM_ID and towerOwners[unitID] then -- a lost-link turret
		GG.ToggleLink(unitID, teamID, false)
		local env = Spring.UnitScript.GetScriptEnv(unitID)
		Spring.UnitScript.CallAsUnit(unitID, env.TeamChange, teamID) -- toggle firing
		LimitTowerType(towerOwners[unitID], teamID, towerDefIDs[unitDefID])
	end
end

function LinkCheck(x, z, controllerID, teamID)
	local nearUnits = GetUnitsInCylinder(x, z, MAX_BUILD_RANGE)
	for _, unitID in pairs(nearUnits) do
		local owner = towerOwners[unitID]
		if owner and not ownedLimits[owner] then -- it is a turret but its owner is dead
			if GetUnitRulesParam(unitID, "LOST_LINK") == 1 then -- make double sure 
				--Spring.Echo("Hey there baby wanna hook up?", UnitDefs[Spring.GetUnitDefID(unitID)].name)
				local towerType = towerDefIDs[Spring.GetUnitDefID(unitID)]
				if buildLimits[controllerID][towerType] > 0 then
					DelayCall(TransferUnit, {unitID, teamID}, 1)
					DelayCall(SetUnitNeutral,{unitID, false}, 1)
					towerOwners[unitID] = controllerID
				end
			end
		end
	end
end
GG.LinkCheck = LinkCheck

function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED
return false end