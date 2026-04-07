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

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
local modOptions = Spring.GetModOptions()

--SyncedRead
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
local COLOURS = GG.GameConstants.colours

-- Mech pickup
local PICKUP_DIST = 100

-- Salvager
local SALVAGER_ID = UnitDefNames["salvager"].id
local SALVAGE_RANGE = 4000
local CMD_DEPOSIT = GG.CustomCommands.GetCmdID("CMD_DEPOSIT")

-- BRV
local BRV_ID = UnitDefNames["brv"].id
local CMD_RECOVER = GG.CustomCommands.GetCmdID("CMD_RECOVER")

local function GetToolTip(unitDefID, discount, action)
	local ud = UnitDefs[unitDefID]
	local weaponTooltip = ud.weapons[1] and "" or ": n/a "
	local tooltip = action .. ": " .. ud.humanName .. " - " .. ud.tooltip .. weaponTooltip .. "\n" 
					.. "Health " .. ud.health .. "\n"
					.. COLOURS.cbills .. "C-Bills cost " .. tonumber(ud.customParams.price) * discount .. "\n"
	if ud.customParams.tonnage then
		tooltip = tooltip .. COLOURS.tonnage .. "Tonnage cost " .. tonumber(ud.customParams.tonnage)
	end
	return tooltip
end

-- Yard
local SALVAGEYARD_ID = UnitDefNames["outpost_salvageyard"] and UnitDefNames["outpost_salvageyard"].id or nil
local CONVERSION_RATE = 40 -- 1000 metal / this = 25
local RATE_PER_TICK = modOptions and modOptions.salvagepertick or 1
local TIME_PER_TICK = 30 * 60 -- 1 minute
local CMD_NEWSALVAGER = -SALVAGER_ID
local SALVAGER_PRICE = tonumber(UnitDefNames["salvager"].customParams.price)
local SALVAGER_TOOLTIP = GetToolTip(SALVAGER_ID, 1, "Build")
local CMD_NEWBRV = -BRV_ID
local BRV_PRICE = tonumber(UnitDefNames["brv"].customParams.price)
local BRV_TOOLTIP = GetToolTip(BRV_ID, 1, "Build")

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
local salvageCache = {} -- featureDefID = true
local salvageArray = {} -- [1] = featureDefID1, ...
local unitPinataLevels = {} -- unitID = 0 or 1 or 2 or 3

local recoverTargets = {} -- unitID = featureID

-- Salvage yard
local yardLevels = {} -- yardLevels[yardID] = 1, 2 or 3
local yardQueues = {} -- yardQueues[yardID] = {{dist = number, id = featureID}, ...}, from furthest to closest
local yardPos = {} -- yardPos[yardID] = {x = x, y = y, z = z}
local yardRaws = {} -- yardRaws[yardID] = metalInHarvestStorage
local yardTeams = {} -- yardTeams[yardID] = teamID
local remainingSlots = {} -- remainingSlots[unitID] = numberOfSlots

local supportCosts = {
	[SALVAGER_ID] = SALVAGER_PRICE,
	[BRV_ID] = BRV_PRICE,
}

local salvagerYards = {} -- salvagerYards[salvagerID] = yardID
local yardSalvagers = {} -- for now; yardSalvagers[yardID] = salvagerID
local idleSalvagers = {} -- idleSalvagers[salvagerID] = true

-- Salvager
local salvageCmdDesc = {
	id 		= CMD.RECLAIM,
	type	= CMDTYPE.ICON_UNIT,
	name 	= " Salvage \n Wreck",
	action	= "reclaim",
	tooltip = "Break down a wreck into components to be salvaged at the salvage yard.",
	cursor	= "Reclaim",
}
local depositCmdDesc = {
	id 		= CMD_DEPOSIT,
	type	= CMDTYPE.ICON_UNIT,
	name 	= " Deposit \n Salvage",
	action	= "deposit",
	tooltip = "Deposit current salvage",
	cursor	= "Unload",
}
local SALVAGER_CMD_DESCS_TO_ADD = {salvageCmdDesc, depositCmdDesc}

-- BRV
local recoverCmdDesc = {
	id 		= CMD_RECOVER,
	type	= CMDTYPE.ICON_UNIT_FEATURE_OR_AREA,
	name 	= " Recover \n Mech",
	action	= "recover",
	tooltip = "Recover a wrecked mech to the salvage yard",
	cursor	= "recover",
}
local BRV_CMD_DESCS_TO_ADD = {recoverCmdDesc}

-- Yard
local newSalvagerCmdDesc = {
	id 		= CMD_NEWSALVAGER,
	type	= CMDTYPE.ICON,
	name 	= " New \n Salvager",
	action	= "newsalvager",
	tooltip = SALVAGER_TOOLTIP,
}
local newBRVCmdDesc = {
	id 		= CMD_NEWBRV,
	type	= CMDTYPE.ICON,
	name 	= " New \n BRV",
	action	= "newbrv",
	tooltip = BRV_TOOLTIP,
}

local function GetMechCmdDesc(unitDefID)
	local cmdDesc = {
		id		= -unitDefID,
		type 	= CMDTYPE.ICON,
		action	= "resurrectmech",
		tooltip = GetToolTip(unitDefID, RECOVER_DISCOUNT, "Recover"),
		name	= "Recover",
	}
	return cmdDesc
end
local scrapMechCmdDesc = {
	id 		= CMD_SCRAP,
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Scrap","Mech", COLOURS.salvage .. "   (+S)"),
	action	= "scrapmech",
	tooltip = "Scraps the mech for ",
}

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

local function SYardoutpost(unitID, level)
	yardLevels[unitID] = level
end
GG.SYardoutpost = SYardoutpost


local function FeatureAttachUpdate(unitID, pieceNum, fakeID, featureID)
	local px, py, pz, dx, dy, dz = Spring.GetUnitPiecePosDir(unitID, pieceNum)
	local front, up = Spring.GetUnitVectors(fakeID)
	local heading = Spring.GetUnitHeading(fakeID)
	local vx, vy, vz = Spring.GetUnitVelocity(unitID)
	Spring.SetFeatureMoveCtrl(featureID,false,1,1,1,1,1,1,1,1,1)
	Spring.SetFeaturePhysics(featureID, px,py,pz, vx,vy,vz, 0,0,0)
	--Spring.SetFeatureDirection(featureID, unpack(front), unpack(up))
	--Spring.Echo("buh?", unpack(up), up[1], up[2], up[3])
	Spring.SetFeatureHeadingAndUpDir(featureID, heading, up[1], up[2], up[3])
end
GG.FeatureAttachUpdate = FeatureAttachUpdate

local featureAttachers = {}

local function FeatureDetach(featureID)
	if not featureAttachers[featureID] then return end
	Spring.DestroyUnit(featureAttachers[featureID].fake, false, true)
	featureAttachers[featureID] = nil
	Spring.SetFeatureBlocking(featureID, true, true, true, true, true, true, true)
end
GG.FeatureDetach = FeatureDetach

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
	FeatureAttachUpdate(unitID, pieceNum, fakeID, featureID)
end
GG.FeatureAttach = FeatureAttach

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
	local featureID = recoverTargets[yardID]
	local info = featureAttachers[featureID]
	local fd = FeatureDefs[Spring.GetFeatureDefID(featureID)]
	local x,y,z = Spring.GetUnitPiecePosDir(yardID, pieceNum)
	local heading = Spring.GetUnitHeading(info.fake)
	local front, up = Spring.GetUnitVectors(info.fake)
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
GG.YardNotifyDone = YardNotifyDone

local function SpawnSalvager(yardID, teamID, salvagerID) -- TODO: rename to 'AssociateSupportVehicle' or something
	local x, y, z = GetUnitPosition(yardID)
	yardPos[yardID] = {["x"] = x, ["y"] = y, ["z"] = z}
	salvagerID = salvagerID or CreateUnit(SALVAGER_ID, x,y,z, 0, teamID)
	if salvagerID then
		salvagerYards[salvagerID] = yardID
		yardSalvagers[yardID] = salvagerID
		GiveOrderToUnit(salvagerID, CMD.RECLAIM, {x, y, z, SALVAGE_RANGE}, {})
	end
end
GG.SpawnSalvager = SpawnSalvager

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == SALVAGEYARD_ID then
		yardLevels[unitID] = 1
		yardQueues[unitID] = {}
		yardRaws[unitID] = 0
		yardTeams[unitID] = teamID
		remainingSlots[unitID] = 4
		InsertUnitCmdDesc(unitID, newSalvagerCmdDesc)
		InsertUnitCmdDesc(unitID, newBRVCmdDesc) -- TODO: lock behind an upgrade
	elseif unitDefID == SALVAGER_ID then
		GG.ClearDefaultCmds(unitID)
		GG.AddSupportCmds(unitID, SALVAGER_CMD_DESCS_TO_ADD)
	elseif unitDefID == BRV_ID then
		GG.ClearDefaultCmds(unitID)
		GG.AddSupportCmds(unitID, BRV_CMD_DESCS_TO_ADD)
	elseif GG.mechCache[unitDefID] then -- a mech
		unitPinataLevels[unitID] = 0
		if builderID and GetUnitDefID(builderID) == SALVAGER_ID then -- TODO: change to brv
			Spring.SetUnitHealth(unitID, 1, 0, 100)
			GG.Delay.DelayCall(Cripple, {unitID}, 1)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	yardLevels[unitID] = nil
	yardQueues[unitID] = nil
	yardRaws[unitID] = nil
	yardTeams[unitID] = nil
	local yardID = salvagerYards[unitID]
	if yardID then
		remainingSlots[yardID] = remainingSlots[yardID] + 1
		salvagerYards[unitID] = nil
	end
	yardSalvagers[unitID] = nil
	idleSalvagers[unitID] = nil
end

function gadget:FeatureCreated(featureID, allyTeamID)
	local fdID = GetFeatureDefID(featureID)
	local fd = FeatureDefs[fdID]
	local cp = fd.customParams
	local amount = salvageCache[fdID]
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
			if (GG.mechCache[unitDefID] or unitDefID == GG.SALVAGER_ID) then 
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
		if dist and dist > 50 and not (unitDefID == BRV_ID and not recoverTargets[unitID]) then -- nothing else to salvage, force RTB
			gadget:UnitHarvestStorageFull(unitID, unitDefID, teamID)
		else
			idleSalvagers[unitID] = true
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local isSalvager = salvagerYards[unitID]
	if cmdID == CMD_DEPOSIT then
		if isSalvager then -- is a Salvager
			idleSalvagers[unitID] = false
			local pos = yardPos[cmdParams[1]]
			SetUnitMoveGoal(unitID, pos.x, pos.y, pos.z)
			--Spring.Echo("Haulin' ass back to base!")
			return true
		else
			return false
		end
	elseif cmdID == CMD_RECOVER and unitDefID == BRV_ID then -- TODO: make a 'isBRV' to include BRV, Heavy BRV, Savior?
		local yardID = salvagerYards[unitID]
		if recoverTargets[yardID] then return false end -- yard already has a corpse loaded, TODO: this can fail if you have multiple BRV
		local featureID = (cmdParams[1] and cmdParams[1] > Game.maxUnits and cmdParams[1] or 0) - Game.maxUnits -- TODO: handle area commands
		if featureID > 0 then
			local x,y,z = GetFeaturePosition(featureID)
			--Spring.Echo("Gonna find me a corpse bride!", x,y,z)
			SetUnitMoveGoal(unitID, x, y, z)
			recoverTargets[unitID] = featureID
			salvageSources[featureID] = nil
			return true
		end
		return false
	elseif cmdID == CMD.RECLAIM and isSalvager then
		if salvageSources[featureID] then
			idleSalvagers[unitID] = false
			return true
		end
		return false
	elseif yardLevels[unitID] then
		if cmdID == CMD_SCRAP then
			local featureID = recoverTargets[unitID]
			local featureDef = FeatureDefs[Spring.GetFeatureDefID(featureID)]
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
					remainingSlots[unitID] = remainingSlots[unitID] - 1 -- TODO: higher slot cost for BRV?
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
					return true
				end
			end
		end
		GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
		return false
	end
	--if cmdID == CMD.RESURRECT then Spring.Echo("Yay rezzin time!") end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_DEPOSIT then
		local yardID = salvagerYards[unitID]
		local dist = GetUnitSeparation(unitID, yardID)
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
			elseif unitDefID == BRV_ID then
				local featureID = recoverTargets[unitID]
				local featureDef = FeatureDefs[Spring.GetFeatureDefID(featureID)]
				--Spring.Echo("Made it back, have a " .. featureDef.name .. " to ressurect!")
				FeatureDetach(featureID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.UnloadFeature, featureID)
				env = Spring.UnitScript.GetScriptEnv(yardID)
				FeatureAttach(yardID, env.mount, featureID)
				recoverTargets[unitID] = nil
				recoverTargets[yardID] = featureID
				local cp = featureDef.customParams
				local targetDefID = cp.was and UnitDefNames[cp.was].id or 0
				local cmdDesc = GetMechCmdDesc(targetDefID)
				Spring.InsertUnitCmdDesc(yardID, cmdDesc)
				local ttCache = scrapMechCmdDesc.tooltip
				scrapMechCmdDesc.tooltip = scrapMechCmdDesc.tooltip .. COLOURS.salvage .. " " .. math.floor(featureDef.metal / CONVERSION_RATE) .. " Salvage"
				Spring.InsertUnitCmdDesc(yardID, scrapMechCmdDesc)
				scrapMechCmdDesc.tooltip = ttCache
			end
			return true, true
		else -- not home yet, keep going
			return true, false
		end
	elseif cmdID == CMD_RECOVER then
		local featureID = recoverTargets[unitID]
		if featureID then
			local dist = Spring.GetUnitFeatureSeparation(unitID, featureID)
			if dist and dist < 50 then
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.RecoverFeature, featureID)
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
	for featureDefID, featureDef in pairs(FeatureDefs) do
		if featureDef.customParams.salvage then
			salvageCache[featureDefID] = tonumber(featureDef.customParams.salvage)
			table.insert(salvageArray, featureDefID)
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
			GG.CheckBuildOptions(yardID, teamID, remainingSlots[yardID])
		end
	end
end

else
--	UNSYNCED
return false end