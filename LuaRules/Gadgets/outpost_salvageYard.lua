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
local SALVAGEYARD_ID = UnitDefNames["outpost_salvageyard"] and UnitDefNames["outpost_salvageyard"].id or nil
local SALVAGER_DEF = UnitDefNames["salvager"]
local SALVAGER_ID = SALVAGER_DEF.id
local SALVAGER_PRICE = tonumber(SALVAGER_DEF.customParams.price)
local SALVAGER_TOOLTIP = "Build: Salvager - " .. SALVAGER_DEF.tooltip .. ": n/a\n" 
						.. "Health " .. SALVAGER_DEF.health .. "\n" 
						.. COLOURS.cbills .. "C-Bills cost " .. SALVAGER_PRICE
local SALVAGE_RANGE = 4000
local CONVERSION_RATE = 40 -- 1000 metal / this = 25
local RATE_PER_TICK = modOptions and modOptions.salvagepertick or 1
local TIME_PER_TICK = 30 * 60 -- 1 minute
local CMD_DEPOSIT = GG.CustomCommands.GetCmdID("CMD_DEPOSIT")
local CMD_NEWSALVAGER = -SALVAGER_ID --GG.CustomCommands.GetCmdID("CMD_NEWSALVAGER")

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

-- Salvage yard
local yardLevels = {} -- yardLevels[yardID] = 1, 2 or 3
local yardQueues = {} -- yardQueues[yardID] = {{dist = number, id = featureID}, ...}, from furthest to closest
local yardPos = {} -- yardPos[yardID] = {x = x, y = y, z = z}
local yardRaws = {} -- yardRaws[yardID] = metalInHarvestStorage
local yardTeams = {} -- yardTeams[yardID] = teamID

local salvagerYards = {} -- salvagerYards[salvagerID] = yardID
local yardSalvagers = {} -- for now; yardSalvagers[yardID] = salvagerID
local idleSalvagers = {} -- idleSalvagers[salvagerID] = true

local depositCmdDesc = {
	id 		= CMD_DEPOSIT,
	type	= CMDTYPE.ICON_UNIT,
	name 	= " Deposit \n Salvage",
	action	= "deposit",
	tooltip = "Deposit current salvage",
	cursor	= "Unload",
}

local newSalvagerCmdDesc = {
	id 		= CMD_NEWSALVAGER,
	type	= CMDTYPE.ICON,
	name 	= " New \n Salvager",
	action	= "newsalvager",
	tooltip = SALVAGER_TOOLTIP,
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

local function SpawnSalvager(yardID, teamID, salvagerID)
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
		InsertUnitCmdDesc(unitID, newSalvagerCmdDesc)
	elseif unitDefID == SALVAGER_ID then
		InsertUnitCmdDesc(unitID, depositCmdDesc)
	elseif GG.mechCache[unitDefID] then -- a mech
		unitPinataLevels[unitID] = 0
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	yardLevels[unitID] = nil
	yardQueues[unitID] = nil
	yardRaws[unitID] = nil
	yardTeams[unitID] = nil
	salvagerYards[unitID] = nil
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
		if dist and dist > 50 then -- nothing else to salvage, force RTB
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
	elseif cmdID == CMD.RECLAIM and isSalvager then
		idleSalvagers[unitID] = false
	elseif yardLevels[unitID] and cmdID == CMD_NEWSALVAGER then
		local cBills = GetTeamResources(teamID, "metal")
		if cBills >= SALVAGER_PRICE then
			GG.DropshipDelivery(Spring.GetUnitRulesParam(unitID, "beaconID"), unitID, teamID, GG.teamSide[teamID] .. "_bishop", SALVAGER_ID, 0, nil, 0, {x = 0, z = 200})
			UseTeamResource(teamID, "m", SALVAGER_PRICE)
			return true
		end
		GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
		return false
	end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_DEPOSIT then
		local yardID = salvagerYards[unitID]
		local dist = GetUnitSeparation(unitID, yardID)
		if dist and dist < 50 then
			local raw = GetUnitHarvestStorage(unitID)
			local salvage = math.floor(raw / CONVERSION_RATE)
			--Spring.Echo("Made it back, have " .. salvage .. " Salvage!")
			yardRaws[yardID] = yardRaws[yardID] + raw
			SetUnitHarvestStorage(yardID, yardRaws[yardID])
			SetUnitHarvestStorage(unitID, 0)
			local pos = yardPos[yardID]
			DelayCall(GiveOrderToUnit, {unitID, CMD.RECLAIM, {pos.x, pos.y, pos.z, SALVAGE_RANGE}, {}}, 1) -- TODO: range change
			return true, true
		else -- not home yet, keep going
			return true, false
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
end

function gadget:GameFrame(n)
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
			GG.CheckBuildOptions(yardID, teamID, 6)
		end
	end
end

else
--	UNSYNCED
return false end