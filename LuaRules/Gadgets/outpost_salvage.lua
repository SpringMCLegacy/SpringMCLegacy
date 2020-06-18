function gadget:GetInfo()
	return {
		name		= "Salvage",
		desc		= "Controls salvagers",
		author		= "FLOZi (C. Lawrence)",
		date		= "22/08/13",
		license 	= "GNU GPL v2",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

-- localisations
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitPosition		= Spring.GetUnitPosition
local GetTeamResources		= Spring.GetTeamResources
--SyncedCtrl
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam
local SpawnProjectile		= Spring.SpawnProjectile
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local BRV_ID = UnitDefNames["brv"].id -- TODO: support multiple brv types
local SALVAGEYARD_ID = UnitDefNames["outpost_salvageyard"].id

local SALVAGE_RANGE = 1000
local CMD_DEPOSIT = GG.CustomCommands.GetCmdID("CMD_DEPOSIT")

-- Variables
local yardLevels = {} -- yardLevels[yardID] = 1, 2 or 3
local yardQueues = {} -- yardQueues[yardID] = {{dist = number, id = featureID}, ...}, from furthest to closest
local yardPos = {} -- yardPos[yardID] = {x = x, y = y, z = z}

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

--[[local function Strip(features)
	for i = #features, 1, -1 do -- iterate over list in reverse so removing doesn't screw with index
		local featureID = features[i]
		local fDefID = Spring.GetFeatureDefID(featureID)
		local fd = FeatureDefs[fDefID]
		local cp = fd.customParams
		if not (cp and cp.was) then
			table.remove(features, i)
		end
	end
end

local function Pop(yardID)
	local index = #yardQueues[yardID]
	local item = yardQueues[yardID][index]
	yardQueues[yardID][index] = nil
	return item
end

local function OrderedPush(yardID, distance, corpseID)
		local x,y,z = Spring.GetFeaturePosition(corpseID)
		Spring.MarkerAddPoint(x,y,z, "Dist: " .. distance .. "   ID: " .. corpseID)
		
	local item = {["dist"] = distance, ["id"] = corpseID}
	local i = #yardQueues[yardID]
	while i > 1 and (yardQueues[yardID][i]["dist"] < distance) do
		i = i - 1
	end
	table.insert(yardQueues[yardID], i+1, item)
end

local function PopulateQueue(yardID)
	local x, _, z = Spring.GetUnitPosition(yardID)
	local features = Spring.GetFeaturesInCylinder(x, z, SALVAGE_RANGE) -- TODO: allow for upgrading range
	Strip(features)
	for _, featureID in pairs(features) do
		local dist = Spring.GetUnitFeatureSeparation(yardID, featureID, true)
		OrderedPush(yardID, dist, featureID)
	end
end
GG.PopulateQueue = PopulateQueue]]

local function SYardoutpost(unitID, level)
	yardLevels[unitID] = level
end
GG.SYardoutpost = SYardoutpost

local function SpawnBRV(yardID, teamID)
	-- TODO: change depending on level? or via buildmenu
	local x, y, z = Spring.GetUnitPosition(yardID)
	yardPos[yardID] = {["x"] = x, ["y"] = y, ["z"] = z}
	local brvID = Spring.CreateUnit("brv", x,y,z, 0, teamID)
	if brvID then
		salvagerYards[brvID] = yardID
		yardSalvagers[yardID] = brvID
		--local item = Pop(yardID)
		Spring.GiveOrderToUnit(brvID, CMD.RECLAIM, {x, y, z, SALVAGE_RANGE}, {}) -- item.id + game.maxUnits
	end
end
GG.SpawnBRV = SpawnBRV

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == SALVAGEYARD_ID then
		yardLevels[unitID] = 1
		yardQueues[unitID] = {}
	elseif unitDefID == BRV_ID then-- TODO: support multiple types of brv
		InsertUnitCmdDesc(unitID, depositCmdDesc)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	yardLevels[unitID] = nil
	yardQueues[unitID] = nil
	salvagerYards[unitID] = nil
	yardSalvagers[unitID] = nil
	idleSalvagers[unitID] = nil
end

function gadget:FeatureCreated(featureID, allyTeamID)
	local fd = FeatureDefs[Spring.GetFeatureDefID(featureID)]
	local cp = fd.customParams
	if cp and cp.was then
		--for yardID, yardQueue in pairs(yardQueues) do
		for yardID, level in pairs(yardLevels) do
			local dist = Spring.GetUnitFeatureSeparation(yardID, featureID, true)
			if dist and dist <= SALVAGE_RANGE then -- TODO: allow for upgrading range
				--OrderedPush(yardID, dist, featureID)
				local salvagerID = yardSalvagers[yardID]
				--Spring.Echo("New corpse!", salvagerID, idleSalvagers[salvagerID])
				if idleSalvagers[salvagerID] then
					local pos = yardPos[yardID]
					Spring.GiveOrderToUnit(salvagerID, CMD.RECLAIM, {pos.x, pos.y, pos.z, SALVAGE_RANGE}, {}) -- TODO: support multiple brv per yard
				end
			end
		end
	end
end

function gadget:UnitIdle(unitID, unitDefID, teamID)
	local yardID = salvagerYards[unitID]
	if yardID then -- is a BRV
		--Spring.Echo("Yawn! Nought to do here boss")
		local dist = Spring.GetUnitSeparation(unitID, yardID)
		if dist and dist > 50 then -- nothing else to salvage, force RTB
			gadget:UnitHarvestStorageFull(unitID, unitDefID, teamID)
		else
			idleSalvagers[unitID] = true
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local isBRV = salvagerYards[unitID]
	if cmdID == CMD_DEPOSIT then
		if isBRV then -- is a BRV
			idleSalvagers[unitID] = false
			local pos = yardPos[cmdParams[1]]
			Spring.SetUnitMoveGoal(unitID, pos.x, pos.y, pos.z)
			--Spring.Echo("Haulin' ass back to base!")
			return true
		else
			return false
		end
	elseif cmdID == CMD.RECLAIM and isBRV then
		idleSalvagers[unitID] = false
	end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_DEPOSIT then
		local yardID = salvagerYards[unitID]
		local dist = Spring.GetUnitSeparation(unitID, yardID)
		if dist and dist < 50 then
			--Spring.Echo("Made it back, have " .. Spring.GetUnitHarvestStorage(unitID) .. " CBills!")
			Spring.AddTeamResource(teamID, "metal", Spring.GetUnitHarvestStorage(unitID))
			Spring.SetUnitHarvestStorage(unitID, 0)
			local pos = yardPos[yardID]
			GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, CMD.RECLAIM, {pos.x, pos.y, pos.z, SALVAGE_RANGE}, {}}, 1) -- TODO: range change
			return true, true
		else -- not home yet, keep going
			return true, false
		end
	end
	return false
end

function gadget:UnitHarvestStorageFull(unitID, unitDefID, teamID)
	--Spring.Echo("Oi vey! I'm full")
	Spring.GiveOrderToUnit(unitID, CMD_DEPOSIT, {salvagerYards[unitID]}, {})
end

function gadget:Initialize()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

end
