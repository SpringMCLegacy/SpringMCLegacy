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
local GetUnitCmdDescs		= Spring.GetUnitCmdDescs
local GetUnitIsDead			= Spring.GetUnitIsDead
local GetUnitRulesParam		= Spring.GetUnitRulesParam
local GetUnitsInCylinder	= Spring.GetUnitsInCylinder
local ValidUnitID 			= Spring.ValidUnitID

--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local SetUnitNeutral		= Spring.SetUnitNeutral
local SetSquareBuildingMask = Spring.SetSquareBuildingMask
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local TURRETCONTROL_ID = UnitDefNames["outpost_turretcontrol"].id
local MAX_BUILD_RANGE = UnitDefs[TURRETCONTROL_ID].buildDistance

-- Variables
local turretDefIDs = {} -- turretDefIDs[unitDefID] = slotCost
GG.turretDefIDs = turretDefIDs
local remainingSlots = {} -- remainingSlots[unitID] = numberOfSlots
local turretOwners = {} -- turretOwners[turretID] = tcID
local tcTeams = {} -- tcTeams[tcID] = teamID

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
		-- automatically build table of turrets
		if cp and cp.baseclass == "turret" then
			turretDefIDs[unitDefID] = tonumber(cp.slotcost) or 1
		end
	end
end

-- TURRETS

-- TODO: this is copy pasta from L208 outpost_dropZone.lua LockHeavy function, generalise it?
local locked = {} -- teamID[unitDefID] = true

local function LockHeavyTurrets(tcID, lock) 
	local cmdDescs = GetUnitCmdDescs(tcID)
	locked[tcID] = locked[tcID] or {}
	for i = 1, #cmdDescs do
		local defID = cmdDescs[i].id
		if defID < 0 then
			local class = turretDefIDs[-defID]
			if class == 2 then
				--Spring.Echo("Hiding", UnitDefs[-defID].name, class)
				locked[tcID][-defID] = lock
				EditUnitCmdDesc(tcID, i, {hidden = lock})		
			end
		end
	end
end
GG.LockHeavyTurrets = LockHeavyTurrets


function LinkCheck(x, z, controllerID, teamID)
	local nearUnits = GetUnitsInCylinder(x, z, MAX_BUILD_RANGE)
	local count = 0
	for _, unitID in pairs(nearUnits) do
		if turretOwners[unitID] then -- it is a turret
			if GetUnitRulesParam(unitID, "LOST_LINK") == 1 then -- it is lost link
				--Spring.Echo("Hey there baby wanna hook up?", UnitDefs[Spring.GetUnitDefID(unitID)].name)
				local slotCost = turretDefIDs[Spring.GetUnitDefID(unitID)]
				if remainingSlots[controllerID] >= count + slotCost then
					count = count + slotCost
					DelayCall(TransferUnit, {unitID, teamID}, 1)
					DelayCall(SetUnitNeutral,{unitID, false}, 1)
					turretOwners[unitID] = controllerID
				end
			end
		end
	end
end
--GG.LinkCheck = LinkCheck

function UpdateTurretSlots(unitID, teamID, delta)
	if not unitID or unitID and Spring.GetUnitIsDead(unitID) then return false end
	remainingSlots[unitID] = (remainingSlots[unitID] or 0) + delta 
	if delta > 0 then -- regaining slots, check for linklost
		local x, _, z = Spring.GetUnitPosition(unitID)
		LinkCheck(x, z, unitID, teamID)
	end
	GG.CheckBuildOptions(unitID, teamID, remainingSlots[unitID] + 1, nil, turretDefIDs) -- +1 here as we want to specify slots to deduct
end
GG.UpdateTurretSlots = UpdateTurretSlots -- for outpost_turretcontrol perk, Anims\Outposts\Outpost_TurretControl LUS

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == TURRETCONTROL_ID then
		tcTeams[unitID] = teamID
		-- Remove all faction turrets that do not belong to the team's side
		local side = GG.teamSide[teamID]
		if not side then return end -- presume team is dead
		local toDelete = {}
		for i, cmdDesc in pairs(GetUnitCmdDescs(unitID)) do
			if cmdDesc.id < 0 then
				local turretDef = UnitDefs[-cmdDesc.id]
				local faction = turretDef and turretDef.customParams.faction
				if faction and faction ~= side then
					toDelete[cmdDesc.id] = true
				end
			end
		end
		for cmdID in pairs(toDelete) do
			RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID))
		end
		-- hide heavy turrets at first
		LockHeavyTurrets(unitID, true) 
		-- N.B. limits are initialised to 4 in the script when mast is deployed
	elseif cp and cp.baseclass == "turret" then
		-- track creation of turrets and their originating beacons so we can give back slots if a turret dies
		if builderID then -- ignore /give turrets
			turretOwners[unitID] = builderID
		end
		-- hide all commands
		GG.ClearCmdDescs(unitID, true)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	local turretOwnerID = turretOwners[unitID]
	if turretOwnerID then -- unit was a turret with owning beacon, open the slot back up
		turretOwners[unitID] = nil
		if ValidUnitID(turretOwnerID) and not GetUnitIsDead(turretOwnerID) then
			UpdateTurretSlots(turretOwnerID, teamID, turretDefIDs[unitDefID]) -- increase limit
		end
	elseif unitDefID == TURRETCONTROL_ID then -- turret control died, kill link and disable
		tcTeams[unitID] = nil
		locked[unitID] = nil
		for turretID, controllerID in pairs(turretOwners) do
			if controllerID == unitID then
				GG.ToggleLink(turretID, teamID, true)
				local env = Spring.UnitScript.GetScriptEnv(turretID)
				Spring.UnitScript.CallAsUnit(turretID, env.TeamChange, GAIA_TEAM_ID) -- toggle firing
				DelayCall(TransferUnit, {turretID, GAIA_TEAM_ID}, 1)
				DelayCall(SetUnitNeutral,{turretID, true}, 1)
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, playerID, synced, fromLua)
	if unitDefID == TURRETCONTROL_ID then
		if cmdID < 0 then
			local slotCost = turretDefIDs[-cmdID]
			if not slotCost then return false end
			
			local tx, ty, tz = unpack(cmdParams)
			local dist = GG.GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
			local cBills = GetTeamResources(teamID, "metal")
			local cost = UnitDefs[-cmdID].metalCost
			-- check for max range, although limited via unit script to only build inside beacon radius... 
			-- ...need to ensure it is within the beacon radius we are built at!
			if dist > MAX_BUILD_RANGE then
				Spring.SendMessageToTeam(teamID, "Too far from Turret Control!")
				GG.PlaySoundForTeam(teamID, "bb_turret_toofar", 1)
			-- check we have the resources
			elseif cBills < cost then
				GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
				Spring.SendMessageToTeam(teamID, "Not enough C-Bills for turret deployment!")	
			-- check we have the slots
			elseif remainingSlots[unitID] >= turretDefIDs[-cmdID] then -- Shouldn't be needed but, bolts and braces
				UpdateTurretSlots(unitID, teamID, -slotCost)
				local success = CreateUnit(-cmdID, tx, ty, tz, 1, teamID, false, false, nil, unitID)
				UseTeamResource(teamID, "m", cost)
				--Spring.Echo("Yo make a turret!", -cmdID, UnitDefs[-cmdID].name, success)
			end
			return false -- don't let the engine build it itself whether we passed the conditions or not
		end
	elseif turretDefIDs[unitDefID] then
		return false -- disallow all commands to turrets
	end
	return true
end


function gadget:UnitGiven(unitID, unitDefID, teamID, oldTeamID)
	if oldTeamID == GAIA_TEAM_ID and turretOwners[unitID] then -- a lost-link turret
		GG.ToggleLink(unitID, teamID, false)
		local env = Spring.UnitScript.GetScriptEnv(unitID)
		Spring.UnitScript.CallAsUnit(unitID, env.TeamChange, teamID) -- toggle firing
		UpdateTurretSlots(turretOwners[unitID], teamID, -turretDefIDs[unitDefID])
	end
end

function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
	if turretDefIDs[unitDefID] then
		return oldTeam == GAIA_TEAM_ID or newTeam == GAIA_TEAM_ID -- TODO: we do want to transfer them with their TC though...
	end
	return true
end


function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		-- check if orders are still too expensive
		for tcID, teamID in pairs(tcTeams) do
			GG.CheckBuildOptions(tcID, teamID, (remainingSlots[tcID] or 0) + 1, nil, turretDefIDs)
		end
	end
end


function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED
return false end