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
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead

--SyncedCtrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local SetUnitNeutral		= Spring.SetUnitNeutral
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local MIN_BUILD_RANGE = tonumber(UnitDefNames["beacon"].customParams.minbuildrange) or 230
local MAX_BUILD_RANGE = UnitDefNames["beacon"].buildDistance

local CMD_UPGRADE = GG.CustomCommands.GetCmdID("CMD_UPGRADE")

-- Variables
local towerDefIDs = {} -- towerDefIDs[unitDefID] = "turret" or "ecm" or "sensor"
local buildLimits = {} -- buildLimits[unitID] = {turret = 4, ecm = 1, sensor = 1}
local towerOwners = {} -- towerOwners[towerID] = beaconID

local outpostDefs = {} -- outpostDefs[unitDefID] = {tooltip = "some string"}
local upgradeIDs = {} -- upgradeIDs[cmdID] = unitDefID
local beaconIDs = {} -- beaconIDs[outpostID] = beaconID
local outpostIDs = {} -- outpostIDs[beaconID] = outpostID

--[[local function HotSwap(unitID, unitDefID, teamID)
	local x,y,z = Spring.GetUnitPosition(unitID)
	if not Spring.GetUnitIsDead(unitID) then
		Spring.DestroyUnit(unitID)
		Spring.Echo("Destroy:", unitID)
	end
	if not teamID then
		teamID = Spring.GetUnitTeam(unitID)
	end
	DelayCall(Spring.CreateUnit,{unitDefID, x,y,z, "s", teamID, false, false, unitID, nil}, 3) -- 3 frame delay appears to be minimum
end]]

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp and cp.towertype then -- automatically build table of towers
			towerDefIDs[unitDefID] = cp.towertype
		elseif name:find("upgrade") then -- automatically build beacon upgrade cmdDescs
			local cBillCost = unitDef.metalCost
			local upgradeCmdDesc = {
				id     = GG.CustomCommands.GetCmdID("CMD_UPGRADE_" .. name),
				type   = CMDTYPE.ICON,
				name   = unitDef.humanName:gsub(" ", "  \n"),
				action = 'upgrade',
				tooltip = "C-Bill cost: " .. cBillCost, -- TODO: add c-bill cost and w/e else
			}
			outpostDefs[unitDefID] = {cmdDesc = upgradeCmdDesc, cost = cBillCost}
			upgradeIDs[upgradeCmdDesc.id] = unitDefID
		end
	end
end

local function AddUpgradeOptions(unitID)
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		Spring.InsertUnitCmdDesc(unitID, outpostInfo.cmdDesc)
	end
end

local function RemoveUpgradeOptions(unitID)
	for outpostDefID, outpostInfo in pairs(outpostDefs) do
		Spring.RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, outpostInfo.cmdDesc.id))
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local unitDef = UnitDefs[unitDefID]
	local cp = unitDef.customParams
	if unitDefID == BEACON_ID then
		buildLimits[unitID] = {["turret"] = 4, ["ecm"] = 1, ["sensor"] = 1}
		AddUpgradeOptions(unitID)
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
		local towerType = towerDefIDs[unitDefID]
		buildLimits[towerOwnerID][towerType] = buildLimits[towerOwnerID][towerType] + 1
		EditUnitCmdDesc(towerOwnerID, FindUnitCmdDesc(towerOwnerID, -unitDefID), {disabled = false, params = {}})
		towerOwners[unitID] = nil
	end
	local beaconID = beaconIDs[unitID]
	if beaconID then -- unit was an upgrade/outpost
		SetUnitRulesParam(unitID, "beaconID", "")
		env = Spring.UnitScript.GetScriptEnv(beaconID)
		Spring.UnitScript.CallAsUnit(beaconID, env.ChangeType, false)
		beaconIDs[unitID] = nil
		outpostIDs[beaconID] = nil
		-- Re-add upgrade options to beacon
		AddUpgradeOptions(beaconID)
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
		for outpostID, beaconID in pairs(beaconIDs) do			
			if beaconID == unitID then
				DelayCall(TransferUnit, {outpostID, newTeam}, 1)
			end
		end
	end
end

function SpawnCargo(beaconID, dropshipID, unitDefID, teamID)
	env = Spring.UnitScript.GetScriptEnv(dropshipID)
	local tx, ty, tz = Spring.GetUnitPosition(dropshipID)
	local outpostID = Spring.CreateUnit(unitDefID, tx, ty, tz, "s", teamID)
	env = Spring.UnitScript.GetScriptEnv(dropshipID)
	Spring.UnitScript.CallAsUnit(dropshipID, env.LoadCargo, beaconID, outpostID)
	beaconIDs[outpostID] = beaconID 
	outpostIDs[beaconID] = outpostID
	-- Let unsynced know about this pairing
	Spring.SetUnitRulesParam(outpostID, "beaconID", beaconID)
end

function DropshipDelivery(unitID, unitDefID, teamID)
	UseTeamResource(teamID, "metal", outpostDefs[unitDefID].cost)
	local tx,ty,tz = Spring.GetUnitPosition(unitID)
	--Spring.SetUnitNoSelect(unitID, true) -- Need a way to undo this on upgrade death
	local dropshipID = Spring.CreateUnit("is_avenger", tx, ty, tz, "s", teamID)
	DelayCall(SpawnCargo, {unitID, dropshipID, unitDefID, teamID}, 1)
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
	if unitDefID == BEACON_ID then
		if cmdID < 0 then
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
		elseif upgradeIDs[cmdID] then
			--Spring.Echo("I'm totally gonna upgrade your beacon bro!")
			RemoveUpgradeOptions(unitID)
			DropshipDelivery(unitID, upgradeIDs[cmdID], teamID)
		elseif cmdID == CMD.SELFD then -- Disallow self-d
			return false
		end
	end
	return true
end

function gadget:Initialize()
	gadget:GamePreload()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

-- localisations
local GetUnitRulesParam			= Spring.GetUnitRulesParam
-- SyncedRead
local GetGameFrame				= Spring.GetGameFrame
-- UnsyncedRead
local GetSelectedUnitsSorted	= Spring.GetSelectedUnitsSorted
-- UnsyncedCtrl
local SelectUnitArray			= Spring.SelectUnitArray
-- variables
local outpostDefIDs = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	if unitDef.name:find("upgrade") then
		outpostDefIDs[unitDefID] = true
	end
end
local lastFrame = 0

function gadget:Update()
	local frameNum = Spring.GetGameFrame()
	if lastFrame == frameNum then
		return --same frame
	end
	lastFrame = frameNum
	--Spring.Echo("unsynced gameframe: " .. lastFrame)
	local selected = GetSelectedUnitsSorted()
	for unitDefID, units in pairs(selected) do
		if outpostDefIDs[unitDefID] then
			for _, unitID in pairs(units) do
				SelectUnitArray({GetUnitRulesParam(unitID, "beaconID")}, true)
			end
		end
	end
end

end
