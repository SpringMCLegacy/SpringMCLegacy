function gadget:GetInfo()
	return {
		name		= "Outpost - Salvage Yard",
		desc		= "Controls salvagers",
		author		= "FLOZi (C. Lawrence)",
		date		= "22/08/13",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled		= true,
	}
end

local CMD_SET_BASE = GG.CustomCommands.GetCmdID("CMD_SET_BASE")

-- Salvager
local SALVAGER_ID = UnitDefNames["salvager"].id
local SALVAGE_RANGE = 4000
local CMD_DEPOSIT = GG.CustomCommands.GetCmdID("CMD_DEPOSIT")

-- BRV
local BRV_ID = UnitDefNames["brv"].id
local CMD_RECOVER = GG.CustomCommands.GetCmdID("CMD_RECOVER")

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
local modOptions = Spring.GetModOptions()

--SyncedRead
local GetFeatureDefID			= Spring.GetFeatureDefID
local GetFeaturePosition		= Spring.GetFeaturePosition
local GetGameFrame				= Spring.GetGameFrame
local GetGroundHeight 			= Spring.GetGroundHeight
local GetProjectilePosition		= Spring.GetProjectilePosition
local GetProjectileType 		= Spring.GetProjectileType
local GetUnitDefID				= Spring.GetUnitDefID
local GetUnitFeatureSeparation 	= Spring.GetUnitFeatureSeparation
local GetUnitHarvestStorage		= Spring.GetUnitHarvestStorage
local GetUnitPosition			= Spring.GetUnitPosition
local GetUnitSeparation 		= Spring.GetUnitSeparation
local GetUnitTeam				= Spring.GetUnitTeam
local GetUnitsInCylinder		= Spring.GetUnitsInCylinder
local GetTeamResources			= Spring.GetTeamResources
local ValidUnitID				= Spring.ValidUnitID
--SyncedCtrl
local CreateFeature				= Spring.CreateFeature
local CreateUnit				= Spring.CreateUnit
local DestroyFeature			= Spring.DestroyFeature
local DestroyUnit				= Spring.DestroyUnit
local InsertUnitCmdDesc			= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc			= Spring.FindUnitCmdDesc
local GetFeatureDefID 			= Spring.GetFeatureDefID
local RemoveUnitCmdDesc			= Spring.RemoveUnitCmdDesc
local SetUnitHarvestStorage 	= Spring.SetUnitHarvestStorage
local SetUnitMoveGoal 			= Spring.SetUnitMoveGoal
local SetUnitRulesParam			= Spring.SetUnitRulesParam
local SetTeamRulesParam			= Spring.SetTeamRulesParam
local UseTeamResource 			= Spring.UseTeamResource
-- UnsyncedCtrl
local GiveOrderToUnit			= Spring.GiveOrderToUnit

-- GG
local DelayCall					 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id

-- Mech pickup
local PICKUP_DIST = 100

-- Yard
local SALVAGEYARD_ID = UnitDefNames["outpost_salvageyard"] and UnitDefNames["outpost_salvageyard"].id or nil
local CONVERSION_RATE = 40 -- 1000 metal / this = 25
local RATE_PER_TICK = modOptions and modOptions.salvagepertick or 1
local TIME_PER_TICK = 30 * 60 -- 1 minute

local RECOVER_DISCOUNT = 0.2 -- 20% cbill cost
GG.RECOVER_DISCOUNT = RECOVER_DISCOUNT -- TODO: move to modOptions
local CMD_SCRAP = GG.CustomCommands.GetCmdID("CMD_SCRAP")

-- Variables
-- Mech pickup
local pieces = {}
local names = {
	["pelvis"] = true,
	["lupperarm"] = true,
	["rupperarm"] = true,
	["turret"] = true,
	["crane_base"] = true,
}

local teamSalvages = {} -- teamID = salvageAmount
local salvageSources = {} -- featureID = {x,z}
local pileCache = {} -- featureDefID = true
local corpseCache = {} -- featureDefID = true
local salvageArray = {} -- [1] = featureDefID1, ...
local unitPinataLevels = {} -- unitID = 0 or 1 or 2 or 3

local recoverTargets = {}

-- Salvage yard
local yardLevels = {} -- yardLevels[yardID] = 1, 2 or 3
local yardQueues = {} -- yardQueues[yardID] = {{dist = number, id = featureID}, ...}, from furthest to closest
local yardPos = {} -- yardPos[yardID] = {x = x, y = y, z = z}
local yardRaws = {} -- yardRaws[yardID] = metalInHarvestStorage
local yardTeams = {} -- yardTeams[yardID] = teamID
local remainingSupportSlots = {} -- remainingSupportSlots[teamID] = numberOfSlots

local function SYardUpgrade(unitID, level)
	yardLevels[unitID] = level
end
GG.SYardUpgrade = SYardUpgrade -- for unit_perks, when there is an upgrade worth implementing


local salvagerYards = {} -- salvagerYards[salvagerID] = yardID
local yardSalvagers = {} -- for now; yardSalvagers[yardID] = salvagerID
local idleSalvagers = {} -- idleSalvagers[salvagerID] = true

-- Salvager
local salvageCmdDesc = {
	id 		= CMD.RECLAIM,
	type	= CMDTYPE.ICON_UNIT_FEATURE_OR_AREA,
	name 	= GG.Pad("Salvage","Wreck"),
	action	= "reclaim",
	tooltip = "Break down a wreck into components to be salvaged at the salvage yard.",
	cursor	= "Reclaim",
}
local depositCmdDesc = { -- also BRV
	id 		= CMD_DEPOSIT,
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Deposit", "Salvage"),
	action	= "deposit",
	tooltip = "Deposit current salvage",
}
-- BRV
local recoverCmdDesc = {
	id 		= CMD_RECOVER,
	type	= CMDTYPE.ICON_UNIT_FEATURE_OR_AREA,
	name 	= GG.Pad("Recover", "Mech"),
	action	= "recover",
	tooltip = "Recover a wrecked mech to the salvage yard",
	cursor	= "recover",
}

-- Support Vehicles related tables ---------------------------------------------------------------------
local supportCosts = {
	[SALVAGER_ID] = tonumber(UnitDefNames["salvager"].customParams.price),
	[BRV_ID] = tonumber(UnitDefNames["brv"].customParams.price),
}

local supportDescs = {
	[SALVAGER_ID] = {GG.setBaseCmdDesc, salvageCmdDesc, depositCmdDesc},
	[BRV_ID] = {GG.setBaseCmdDesc, recoverCmdDesc},
}

-- Yard Support Ordering Descs
local newSalvagerCmdDesc = {
	id 		= -SALVAGER_ID,
	type	= CMDTYPE.ICON,
	action	= "newsalvager",
	tooltip = GG.GetBuildToolTip(SALVAGER_ID, 1, "Build"),
}
local newBRVCmdDesc = {
	id 		= -BRV_ID,
	type	= CMDTYPE.ICON,
	action	= "newbrv",
	tooltip = GG.GetBuildToolTip(BRV_ID, 1, "Build"),
}

-- Salavge resource related functions -------------------------------------------------------------------
local function PinataLevel(unitID, delta)
	if delta then
		unitPinataLevels[unitID] = unitPinataLevels[unitID] + delta
	end
	return unitPinataLevels[unitID] or 0 -- incase of non-mech killer
end
GG.PinataLevel = PinataLevel

local function GetTeamSalvage(teamID)
	return teamSalvages[teamID] or 0
end
GG.GetTeamSalvage = GetTeamSalvage

local function ChangeTeamSalvage(teamID, delta)
	teamSalvages[teamID] = (teamSalvages[teamID] or 0) + delta
	SetTeamRulesParam(teamID, "SALVAGE", teamSalvages[teamID])
end
GG.ChangeTeamSalvage = ChangeTeamSalvage


-- BRV related functions --------------------------------------------------------------------------------
local function GetMechCmdDesc(unitDefID)
	local cmdDesc = {
		id		= -unitDefID,
		type 	= CMDTYPE.ICON,
		action	= "resurrectmech",
		tooltip = GG.GetBuildToolTip(unitDefID, RECOVER_DISCOUNT, "Recover"),
		name	= "Recover",
	}
	return cmdDesc
end

local function FeatureAttachUpdate(unitID, pieceNum, fakeID, featureID)
	local px, py, pz, dx, dy, dz = Spring.GetUnitPiecePosDir(unitID, pieceNum)
	local front, up = Spring.GetUnitVectors(fakeID)
	local heading = Spring.GetUnitHeading(fakeID)
	local vx, vy, vz = Spring.GetUnitVelocity(unitID) -- TODO: need to add _piece_ velocity here somehow
	Spring.SetFeatureMoveCtrl(featureID,false,1,1,1,1,1,1,1,1,1)
	Spring.SetFeaturePhysics(featureID, px,py,pz, vx,vy,vz, 0,0,0)
	--Spring.SetFeatureDirection(featureID, unpack(front), unpack(up))
	--Spring.Echo("buh?", unpack(up), up[1], up[2], up[3])
	Spring.SetFeatureHeadingAndUpDir(featureID, heading, up[1], up[2], up[3])
end
--GG.FeatureAttachUpdate = FeatureAttachUpdate 

local featureAttachers = {}
local brvAttachers = {}

local function FeatureDetach(featureID)
	if not featureAttachers[featureID] then return end
	Spring.DestroyUnit(featureAttachers[featureID].fake, false, true)
	brvAttachers[featureAttachers[featureID]] = nil
	featureAttachers[featureID] = nil
	Spring.SetFeatureBlocking(featureID, true, true, true, true, true, true, true)
end
--GG.FeatureDetach = FeatureDetach

local function FeatureAttach(unitID, pieceNum, featureID, direct)
	--FeatureDetach(featureID)
	Spring.SetFeatureBlocking(featureID, false, false, false, false, false, false, false)
	local x,y,z = Spring.GetUnitPiecePosDir(unitID, pieceNum)
	local fakeID = direct and unitID or featureAttachers[featureID] and featureAttachers[featureID].fake or Spring.CreateUnit("fake", x,y,z, 0, Spring.GetUnitTeam(unitID))
	if not direct then
		Spring.UnitAttach(unitID, fakeID, pieceNum, true)
	end
	featureAttachers[featureID] = {
		fake = fakeID, 
		unit = unitID, 
		piece = pieceNum
	}
	brvAttachers[unitID] = featureID
	FeatureAttachUpdate(unitID, pieceNum, fakeID, featureID)
end
GG.FeatureAttach = FeatureAttach -- called by LUS Vehicle.lua

local function Cripple(unitID, unitDefID, lArm, rArm)
	local info = GG.lusHelper[unitDefID]
	env = Spring.UnitScript.GetScriptEnv(unitID)
	Spring.UnitScript.CallAsUnit(unitID, env.limbHPControl, "left_leg", 10000, nil, true)
	Spring.UnitScript.CallAsUnit(unitID, env.limbHPControl, "right_leg", 10000, nil, true)
	Spring.UnitScript.CallAsUnit(unitID, env.limbHPControl, "left_arm", lArm and 10000 or info.limbHPs.left_arm * 0.1, nil, true, not lArm)
	Spring.UnitScript.CallAsUnit(unitID, env.limbHPControl, "right_arm", rArm and 10000 or info.limbHPs.right_arm * 0.1, nil, true, not rArm)
	Spring.SetUnitHealth(unitID, 1)
	for ammoType, maxAmmo in pairs(info.ammoTypeWeapCounts) do
		Spring.UnitScript.CallAsUnit(unitID, env.ChangeAmmo, ammoType, -1000)
	end
end

local function YardNotifyDone(yardID, teamID, pieceNum)
	local targetInfo = recoverTargets[yardID]
	local featureID = targetInfo.fID
	local attachInfo = featureAttachers[featureID]
	local fd = FeatureDefs[Spring.GetFeatureDefID(featureID)]
	local x,y,z = Spring.GetUnitPiecePosDir(yardID, pieceNum)
	local heading = Spring.GetUnitHeading(attachInfo.fake)
	local front, up = Spring.GetUnitVectors(attachInfo.fake)
	FeatureDetach(featureID)
	DestroyFeature(featureID)
	local mechDefID = UnitDefNames[fd.customParams.was].id
	local mechID = CreateUnit(mechDefID, x,y,z, 0, teamID)
	Spring.SetUnitHeadingAndUpDir(mechID, heading,  up[1], up[2], up[3])
	local lArm = fd.name:find("_left") or fd.name:find("_both")
	local rArm = fd.name:find("_right") or fd.name:find("_both")
	Cripple(mechID, mechDefID, lArm, rArm)
	recoverTargets[yardID] = nil
end
GG.YardNotifyDone = YardNotifyDone -- called by LUS Anims\Outpost_SalvageYard.lua


local function AssociateSupport(yardID, teamID, supportID)
	--Spring.Echo("AssociateSupport", yardID, teamID, supportID)
	local x, y, z = GetUnitPosition(yardID)
	yardPos[yardID] = {["x"] = x, ["y"] = y, ["z"] = z}
	local unitDefID = Spring.GetUnitDefID(supportID)
	if supportID then
		salvagerYards[supportID] = yardID
		yardSalvagers[yardID] = supportID
		if unitDefID == SALVAGER_ID then
			GiveOrderToUnit(supportID, CMD.RECLAIM, {x, y, z, SALVAGE_RANGE}, {})
		elseif unitDefID == BRV_ID and brvAttachers[supportID] then
			GiveOrderToUnit(supportID, CMD_DEPOSIT, {yardID}, {})
		else
			GiveOrderToUnit(supportID, CMD.MOVE, {x + math.random(-200, 200), y, z + math.random(-200, 200)}, {})
		end
	end
end
GG.AssociateSupport = AssociateSupport

local function ChangeSupportLance(teamID, unitID, delta)
	remainingSupportSlots[teamID] = remainingSupportSlots[teamID] - delta
	local current = tonumber(Spring.GetTeamRulesParam(teamID, "SUPPORT_LANCE") or 0)
	local new = current + delta
	--Spring.Echo("outpost_salvageyard ChangeSupportLance", delta, current, new, new > 0)
	Spring.SetTeamRulesParam(teamID, "SUPPORT_LANCE", new)
	SendToUnsynced("LANCE", teamID, unitID, 4, false)
	SendToUnsynced("SUPPORT_LANCE", teamID, new > 0)
end
GG.ChangeSupportLance = ChangeSupportLance

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == SALVAGEYARD_ID then
		yardLevels[unitID] = 1
		yardQueues[unitID] = {}
		yardRaws[unitID] = 0
		yardTeams[unitID] = teamID
		InsertUnitCmdDesc(unitID, newSalvagerCmdDesc)
		InsertUnitCmdDesc(unitID, newBRVCmdDesc) -- TODO: lock behind an upgrade
	elseif supportCosts[unitDefID] then
		ChangeSupportLance(teamID, unitID, 1)
		GG.ClearDefaultCmds(unitID)
		GG.AddSupportCmds(unitID, supportDescs[unitDefID])
	elseif GG.mechCache[unitDefID] then -- a mech
		unitPinataLevels[unitID] = 0
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	yardLevels[unitID] = nil
	yardQueues[unitID] = nil
	yardRaws[unitID] = nil
	yardTeams[unitID] = nil
	local yardID = salvagerYards[unitID]
	if yardID then
		salvagerYards[unitID] = nil
	end
	yardSalvagers[unitID] = nil
	idleSalvagers[unitID] = nil
	if supportCosts[unitDefID] then
		ChangeSupportLance(teamID, unitID, -1)
	end
end

function gadget:FeatureCreated(featureID, allyTeamID)
	local fdID = GetFeatureDefID(featureID)
	local fd = FeatureDefs[fdID]
	local cp = fd.customParams
	local amount = pileCache[fdID]
	if amount then
		local x,y,z = GetFeaturePosition(featureID)
		--Spring.Echo("New pile!", amount, x,y,z)
		salvageSources[featureID] = {
			["x"] = x, 
			["z"] = z,
			["amount"] = amount * (modOptions.salvageperpile or 1),
		}
	elseif cp and cp.was then
		local toHide = {}
		local somethingToHide = false
		if cp.left then
			toHide["lupperarm"] = true
			toHide["llowerarm"] = true
			somethingToHide = true
		end
		if cp.right then
			toHide["rupperarm"] = true
			toHide["rlowerarm"] = true
			somethingToHide = true
		end
		if somethingToHide then
			local fPieces = Spring.GetFeaturePieceMap(featureID)
			for pieceName in pairs(toHide) do
				if fPieces[pieceName] then
					Spring.SetFeaturePieceVisible(featureID, fPieces[pieceName], false)
				end
			end
		end
		for yardID, level in pairs(yardLevels) do
			local dist = GetUnitFeatureSeparation(yardID, featureID, true)
			if dist and dist <= SALVAGE_RANGE then -- TODO: allow for upgrading range
				local salvagerID = yardSalvagers[yardID]
				--Spring.Echo("New corpse!", salvagerID, idleSalvagers[salvagerID])
				if idleSalvagers[salvagerID] then
					local pos = yardPos[yardID]
					GiveOrderToUnit(salvagerID, CMD.RECLAIM, {pos.x, pos.y, pos.z, SALVAGE_RANGE}, {}) -- TODO: support multiple salvagers per yard?
				end
			end
		end
	end
end

function gadget:FeatureDestroyed(featureID)
	salvageSources[featureID] = nil
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	local weap, piece = GetProjectileType(proID)
	--Spring.Echo("PC", proID, proOwnerID, weaponID, name, defID, weap, piece)
	if ValidUnitID(proOwnerID) and piece then
		if Spring.GetPieceProjectileName then
			local name = Spring.GetPieceProjectileName(proID) -- TODO: Removed in Recoil, waiting for it to be brought back so we can whitelist
			pieces[proID] = names[name or ""]
		else
			local unitDefID = GetUnitDefID(proOwnerID)
			local ud = UnitDefs[unitDefID]
			if (GG.mechCache[unitDefID] or unitDefID == SALVAGER_ID) then 
				pieces[proID] = true 
			end
		end
	end
end
	
function gadget:ProjectileDestroyed(proID)
	if pieces[proID] then
		local x,_,z = GetProjectilePosition(proID)
		CreateFeature(salvageArray[math.random(#salvageArray)], x,GetGroundHeight(x,z),z)
		pieces[proID] = nil
	end
end

function gadget:UnitIdle(unitID, unitDefID, teamID)
	local yardID = salvagerYards[unitID]
	if yardID then -- is a Salvager
		--Spring.Echo("Yawn! Nought to do here boss")
		local dist = GetUnitSeparation(unitID, yardID)
		if dist and dist > 50 -- nothing else to salvage, force RTB
		and not (unitDefID == BRV_ID and recoverTargets[yardID] and recoverTargets[yardID].loaded) then -- exempt BRV if there is a mech loaded
			gadget:UnitHarvestStorageFull(unitID, unitDefID, teamID)
		else
			idleSalvagers[unitID] = true
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local isSalvager = supportCosts[unitDefID] --salvagerYards[unitID]
	if cmdID == CMD_DEPOSIT then
		if isSalvager then -- is a Salvager
			idleSalvagers[unitID] = false
			local yardID = salvagerYards[unitID]
			local pos = yardPos[yardID]
			SetUnitMoveGoal(unitID, pos.x, pos.y, pos.z)
			--Spring.Echo("Haulin' ass back to base!")
			return true
		else
			return false
		end
	elseif cmdID == CMD_RECOVER and unitDefID == BRV_ID then -- TODO: make a 'isBRV' to include BRV, Heavy BRV, Savior?
		local yardID = salvagerYards[unitID]
		local target = recoverTargets[yardID]
		if target and target.loaded then return false end -- yard already has a corpse loaded
		local featureID = (cmdParams[1] and cmdParams[1] > Game.maxUnits and cmdParams[1] or 0) - Game.maxUnits -- TODO: handle area commands
		if featureID > 0 then
			-- First check if the target is a mech
			local featureDefID = Spring.GetFeatureDefID(featureID)
			local featureDef = FeatureDefs[featureDefID]
			local baseClass = featureDef.customParams.wasbaseclass
			if not baseClass or baseClass ~= "mech" then 
				Spring.SendMessageToTeam(teamID, "Cannot recover that wreck - It is not a mech")
				return false 
			end
			-- Target is a mech, proceed
			local pelvis = Spring.GetFeaturePieceMap(featureID).pelvis
			local fx, fy, fz = Spring.GetFeaturePiecePosDir(featureID, pelvis)
			local fHeading = Spring.GetFeatureHeading(featureID)
			local radius = Spring.GetFeatureRadius(featureID)
			local dx,dy,dz = GG.Vector.RotateY(0, 0 , -radius * 3, GG.Vector.HeadingToRadians(fHeading))
			local x,y,z = fx+dx, fy+dy, fz+dz
			--Spring.Echo("Gonna find me a corpse bride!", "pelvis", pelvis, "fH", fHeading, "angle", math.deg(GG.Vector.HeadingToRadians(fHeading)), "r", radius, "F xyz", fx,fy,fz, "D xyz", dx,dy,dz, "xyz", x,y,z)
			--Spring.MarkerAddPoint(x,y,z)
			SetUnitMoveGoal(unitID, x, y, z, 5)
			recoverTargets[yardID] = {
				fID = featureID,
				yID = yardID,
				brvID = unitID,
				pos = {
					['x'] = x,
					['y'] = y,
					['z'] = z,
				},
				loaded = false,
			}
			salvageSources[featureID] = nil
			return true
		end
		return false
	elseif cmdID == CMD.RECLAIM and isSalvager then
		local area = cmdParams[4]
		if area and area > 0 then 
			return true 
		end
		local featureID = (cmdParams[1] and cmdParams[1] > Game.maxUnits and cmdParams[1] or 0) - Game.maxUnits
		if featureID > 0 then
			local featureDefID = GetFeatureDefID(featureID)
			if corpseCache[featureDefID] then
				idleSalvagers[unitID] = false
				return true
			end
		end
		return false
	elseif cmdID == CMD_SET_BASE and isSalvager then
		local yardID = cmdParams[1]
		--Spring.Echo("AllowCommand CMD_SET_BASE", yardID)
		if yardLevels[yardID] then -- it is a yard, afterall
			AssociateSupport(yardID, teamID, unitID)
			return true
		end
		return false
	elseif yardLevels[unitID] then -- it is a yard
		if cmdID == CMD_SCRAP then
			local featureID = recoverTargets[unitID].fID
			local featureDef = FeatureDefs[GetFeatureDefID(featureID)]
			-- TODO: Maybe add a animation in the yard script and have it be non-instant
			local amount = math.floor(featureDef.metal / CONVERSION_RATE)
			ChangeTeamSalvage(teamID, amount)
			FeatureDetach(featureID)
			DestroyFeature(featureID)
			Spring.RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SCRAP)) -- TODO: hide / disable instead?
		elseif cmdID < 0 then 
			local cBills = GetTeamResources(teamID, "metal")
			local supportCost = supportCosts[-cmdID]
			if supportCost then -- purchasing a support vehicle
				if cBills >= supportCost then
					GG.DropshipDelivery(Spring.GetUnitRulesParam(unitID, "beaconID"), unitID, teamID, GG.teamSide[teamID] .. "_bishop", -cmdID, 0, nil, 0, {x = 0, z = 200})
					UseTeamResource(teamID, "m", supportCosts[-cmdID])
					return true
				end
			else -- Rezzing a mech, in theory
				local cost = tonumber(UnitDefs[-cmdID].customParams.price) * RECOVER_DISCOUNT
				local tons = tonumber(UnitDefs[-cmdID].customParams.tonnage)
				local tonnage = GetTeamResources(teamID, "energy")
				if cBills >= cost and tonnage >= tons then
					env = Spring.UnitScript.GetScriptEnv(unitID)
					Spring.UnitScript.CallAsUnit(unitID, env.Recover, tons)
					Spring.RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID))
					UseTeamResource(teamID, "metal", cost)
					UseTeamResource(teamID, "energy", tons)
					return true
				end
			end
			GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
		end
		return false
	end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_DEPOSIT then
		local yardID = salvagerYards[unitID]
		local dist = GetUnitSeparation(unitID, yardID)
		--Spring.Echo("CMD_DEPOSIT", unitID, yardID, dist)
		if dist and dist < 50 then
			if unitDefID == SALVAGER_ID then -- depositing salvage
				local raw = GetUnitHarvestStorage(unitID)
				local salvage = math.floor(raw / CONVERSION_RATE)
				--Spring.Echo("Made it back, have " .. salvage .. " Salvage!")
				yardRaws[yardID] = yardRaws[yardID] + raw
				SetUnitHarvestStorage(yardID, yardRaws[yardID])
				SetUnitHarvestStorage(unitID, 0)
				local pos = yardPos[yardID]
				DelayCall(GiveOrderToUnit, {unitID, CMD.RECLAIM, {pos.x, pos.y, pos.z, SALVAGE_RANGE}, {}}, 1) -- TODO: range change
			elseif unitDefID == BRV_ID and recoverTargets[yardID] then
				local featureID = recoverTargets[yardID].fID
				local featureDef = FeatureDefs[Spring.GetFeatureDefID(featureID)]
				--Spring.Echo("Made it back, have a " .. featureDef.name .. " to ressurect!")
				FeatureDetach(featureID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.UnloadFeature, featureID)
				env = Spring.UnitScript.GetScriptEnv(yardID)
				FeatureAttach(yardID, env.mount, featureID)
				recoverTargets[yardID].loaded = true
				local cp = featureDef.customParams
				local targetDefID = cp.was and UnitDefNames[cp.was].id or 0
				local cmdDesc = GetMechCmdDesc(targetDefID)
				Spring.InsertUnitCmdDesc(yardID, cmdDesc)
				local ttCache = scrapMechCmdDesc.tooltip
				scrapMechCmdDesc.tooltip = scrapMechCmdDesc.tooltip .. COLOURS.salvage .. " " .. math.floor(featureDef.metal / CONVERSION_RATE) .. " Salvage"
				Spring.InsertUnitCmdDesc(yardID, scrapMechCmdDesc)
				scrapMechCmdDesc.tooltip = ttCache
			end
			--Spring.Echo("CommandFallback consume CMD_DEPOSIT")
			return true, true
		else -- not home yet, keep going
			--Spring.Echo("CommandFallback again CMD_DEPOSIT")
			return true, false
		end
	elseif cmdID == CMD_RECOVER then
		local yardID = salvagerYards[unitID]
		local info = recoverTargets[yardID]
		if info then
			-- TODO: maybe cache turret piece lookup?
			local turret = Spring.GetUnitPieceMap(unitID).turret
			local x,y,z = Spring.GetUnitPiecePosDir(unitID, turret)
			local dist = GG.Vector.DistanceBetween(x, y, z, info.pos.x, info.pos.y, info.pos.z)
			--Spring.Echo("CMD_RECOVER distance", dist, "feature radius is", Spring.GetFeatureRadius(featureID))
			if dist and dist < 35 then
				--Spring.Echo("CMD_RECOVER within distance")
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.RecoverFeature, info.fID)
				gadget:UnitHarvestStorageFull(unitID, unitDefID, teamID)
				return true, true
			else -- not there yet, keep going
				return true, false
			end
		end
	end
	return false
end

function gadget:UnitHarvestStorageFull(unitID, unitDefID, teamID)
	--Spring.Echo("Oi vey! I'm full")
	GiveOrderToUnit(unitID, CMD_DEPOSIT, {salvagerYards[unitID]}, {})
end

function gadget:Initialize()
	Script.SetWatchWeapon(-1, true) -- pieces
	for _, teamID in pairs(Spring.GetTeamList()) do
		remainingSupportSlots[teamID] = 4
	end
	for featureDefID, featureDef in pairs(FeatureDefs) do
		if featureDef.customParams.salvage then
			pileCache[featureDefID] = tonumber(featureDef.customParams.salvage)
			table.insert(salvageArray, featureDefID)
		elseif featureDef.customParams.was then
			corpseCache[featureDefID] = tonumber(featureDef.metal)
		end
	end
	for _, featureID in ipairs(Spring.GetAllFeatures()) do
		local allyTeam = Spring.GetFeatureAllyTeam(featureID)
		gadget:UnitCreated(featureID, allyTeam)
	end
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	Spring.AssignMouseCursor("setbase", "cursordefend")
	Spring.AssignMouseCursor("recover", "cursorpickup")
	Spring.SetCustomCommandDrawData(CMD_RECOVER, "recover", {1,0.7,0.9,0.8}, true)
end

function gadget:GameFrame(n)
	-- every frame
	for featureID, info in pairs(featureAttachers) do
		FeatureAttachUpdate(info.unit, info.piece, info.fake, featureID)
	end
	
	if n % TIME_PER_TICK == 5 then
		for yardID, teamID in pairs(yardTeams) do
			-- turn water into wine
			local totalRaw = yardRaws[yardID]
			if totalRaw and totalRaw > 0 then
				local totalSalvage = math.floor(totalRaw / CONVERSION_RATE)
				local rawAvailable = math.min(CONVERSION_RATE, totalRaw)
				local salvageAvailable = math.min(rawAvailable/CONVERSION_RATE, RATE_PER_TICK)
				GG.ChangeTeamSalvage(teamID, salvageAvailable * yardLevels[yardID])
				-- consume the raw
				yardRaws[yardID] = yardRaws[yardID] - rawAvailable
				SetUnitHarvestStorage(yardID, yardRaws[yardID])
			end
		end
	end
	if n % 10 == 5 then -- 3x a second
		for featureID, info in pairs(salvageSources) do
			local units = GetUnitsInCylinder(info.x, info.z, PICKUP_DIST)
			if units[1] then
				local unitDefID = GetUnitDefID(units[1])
				if GG.mechCache[unitDefID] then
					local teamID = GetUnitTeam(units[1])
					ChangeTeamSalvage(teamID, info.amount)
					DestroyFeature(featureID)
				end
			end
		end
		for yardID, teamID in pairs(yardTeams) do
			GG.CheckBuildOptions(yardID, teamID, remainingSupportSlots[teamID])
		end
	end
end

else
--	UNSYNCED

function gadget:Initialize()
	Spring.SetCustomCommandDrawData(CMD_RECOVER, "recover", {1,0.7,0.9,0.8}, true)
end
	
function gadget:DefaultCommand(targetType, targetID)
	local recoverableTarget = false
	if targetType == "feature" then
		local targetDefID = Spring.GetFeatureDefID(targetID)
		local targetDef = FeatureDefs[targetDefID]
		recoverableTarget = targetDef.customParams.wasbaseclass == "mech"
    end
	  
	local cmd = false
	for _,u in ipairs(Spring.GetSelectedUnits()) do
		local unitDefID = Spring.GetUnitDefID(u)
		if unitDefID == BRV_ID then
			return recoverableTarget and CMD_RECOVER or CMD.MOVE
		elseif unitDefID == SALVAGER_ID then
			return targetType == "feature" and CMD.RECLAIM or CMD.MOVE
		end
	end
    
	return -- let engine handle it
end

--return false 
end