function gadget:GetInfo()
	return {
		name		= "Purchasing",
		desc		= "Controls purchasing abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "31/08/13",
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
local AreTeamsAllied		= Spring.AreTeamsAllied
local GetGameFrame			= Spring.GetGameFrame
local GetTeamResources		= Spring.GetTeamResources
local GetUnitPosition		= Spring.GetUnitPosition
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local TransferUnit			= Spring.TransferUnit
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitNeutral		= Spring.SetUnitNeutral
local SetUnitRotation		= Spring.SetUnitRotation
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local BEACON_ID = UnitDefNames["beacon"].id
local C3_ID = UnitDefNames["upgrade_c3array"].id
local DROPSHIP_DELAY = 30 * 30 -- 30s
local DAMAGE_REWARD_MULT = 0.2
local KILL_REWARD_MULT = 0.5

-- local NUM_ICONS_PER_PAGE = 3 * 8
	
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local sendOrderCmdDesc = {
	id = CMD_SEND_ORDER,
	type   = CMDTYPE.ICON,
	name   = "Submit \nOrder ",
	action = 'submit_order',
	tooltip = "Submit your purchasing order",
}

-- Variables
local typeStrings = {"lightmech", "mediummech", "heavymech", "assaultmech", "vehicle", "vtol", "aero"}
local menuCmdDescs = {}
local menuCmdIDs = {}
for i, typeString in ipairs(typeStrings) do
	local cmdID = GG.CustomCommands.GetCmdID("CMD_MENU_" .. typeString:upper())
	menuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = typeString, -- TODO: nicely formatted names? or use textures
		action = 'menu',
		tooltip = "Purchase " .. typeString,
	}
	menuCmdIDs[cmdID] = typeString
end

local unitTypes = {} -- unitTypes[unitDefID] = "lightmech" etc from typeStrings
local orderCosts = {} -- orderCosts[unitID] = cost
local orderSizes = {} -- orderSizes[unitID] = size
local teamSlotsRemaining = {} -- teamSlotsRemaining[teamID] = numberOfUnitsSlotsRemaining
local dropZones = {} -- dropZones[unitID] = teamID
local teamDropZones = {} -- teamDropZone[teamID] = unitID

local function AddBuildMenu(unitID)
	InsertUnitCmdDesc(unitID, sendOrderCmdDesc)
	for i, cmdDesc in ipairs(menuCmdDescs) do
		InsertUnitCmdDesc(unitID, cmdDesc)
	end
end

local function ClearBuildOptions(unitID, everything)
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id < 0 or everything then
			EditUnitCmdDesc(unitID, i, {hidden = true})
		end
	end
end

local function ShowBuildOptionsByType(unitID, unitType)
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id < 0 and unitTypes[-cmdDesc.id] == unitType then
			EditUnitCmdDesc(unitID, i, {hidden = false})
		end
	end
end

local function ResetBuildQueue(unitID)
	local orderQueue = Spring.GetFactoryCommands(unitID)
	for i, order in ipairs(orderQueue) do
		Spring.GiveOrderToUnit(unitID, CMD.REMOVE, {order.tag}, {"ctrl"})
	end
end

local function CheckBuildOptions(unitID, teamID, money, cmdID)
	local weightLeft = GetTeamResources(teamID, "energy")
	local cmdDescs = GetUnitCmdDescs(unitID)
	for cmdDescID = 1, #cmdDescs do
		local buildDefID = cmdDescs[cmdDescID].id
		local cmdDesc = cmdDescs[cmdDescID]
		if cmdDesc.id ~= cmdID then
			local currParam = cmdDesc.params[1] or ""
			local cCost, tCost
			if buildDefID < 0 then -- a build order
				cCost = UnitDefs[-buildDefID].metalCost
				tCost = UnitDefs[-buildDefID].energyCost
			else
				cCost = GG.CommandCosts[buildDefID] or 0
				tCost = 0
			end
			if cCost > 0 and (teamSlotsRemaining[teamID] - (orderSizes[teamID] or 0)) < 1 and (currParam == "C" or currParam == "" or currParam == "L") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"L"}})
			elseif cCost > money and (currParam == "" or currParam == "C") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"C"}})
			elseif tCost > weightLeft then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"T"}})
			else
				if cmdDesc.disabled and (currParam == "C" or currParam == "L") then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = {}})
				end
			end
		end
	end
end

local DROPSHIP_COOLDOWN = DROPSHIP_DELAY + 10 * 30 -- 10s
local startMin, startSec = GG.FramesToMinutesAndSeconds(DROPSHIP_COOLDOWN)
local coolDowns = {} -- coolDowns[teamID] = enableFrame

function SendButtonCoolDown(unitID, teamID)
	EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = true, name = startMin .. ":" .. startSec})
	local enableFrame = GetGameFrame() + DROPSHIP_COOLDOWN
	coolDowns[teamID] = enableFrame
	Spring.SetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN", enableFrame) -- frame this team can call dropship again
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if dropZones[unitID] then
		local typeString = menuCmdIDs[cmdID]
		local rightClick = cmdOptions.right
		if typeString then
			ClearBuildOptions(unitID)
			ShowBuildOptionsByType(unitID, typeString)
			return true
		elseif cmdID < 0 then
			-- Don't allow dropzones to consider towers
			local towerType = UnitDefs[-cmdID].customParams.towertype
			if towerType then return false end
			
			local cost = UnitDefs[-cmdID].metalCost
			local runningTotal = orderCosts[unitID] or 0
			local runningSize = orderSizes[unitID] or 0
			local money = GetTeamResources(teamID, "metal")
			if not rightClick then
				if (teamSlotsRemaining[teamID] - runningSize) < 1 then return false end
				if runningTotal + cost < money then -- check we can afford it
					Spring.SendMessageToTeam(teamID, "Running Total: " .. runningTotal + cost)
					orderCosts[unitID] = runningTotal + cost
					orderSizes[unitID] = runningSize + 1
					CheckBuildOptions(unitID, teamID, money - (runningTotal + cost), cmdID)
					return true
				else
					return false -- not enough money
				end
			elseif runningSize > 0 then  -- only allow removal if order contains units (prevent -ve running totals!)
				local cmdDesc = GetUnitCmdDescs(unitID, FindUnitCmdDesc(unitID, cmdID))[1] -- TODO: This is just awful
				local currNumber = tonumber(cmdDesc.params[1]) or 0
				if currNumber > 0 then -- only allow if more than 1 of **this** unit currently on order
					orderCosts[unitID] = runningTotal - cost
					orderSizes[unitID] = runningSize - 1
					CheckBuildOptions(unitID, teamID, money - (runningTotal - cost))
					return true
				else
					return false
				end
			end
			
		elseif cmdID == CMD_SEND_ORDER then
			local orderQueue = Spring.GetFullBuildQueue(unitID)
			local money = GetTeamResources(teamID, "metal")
			local cost = orderCosts[unitID]
			-- check we can afford the order; possible that a previously affordable order is now too much e.g. if towers have been purchased
			if cost > money then return false end
			
			for i, order in pairs(orderQueue) do -- we need to double all orders for vehicles
				for orderDefID, count in pairs(order) do
					if unitTypes[orderDefID] == "vehicle" then -- TODO: vtol and aero?
						orderQueue[i][orderDefID] = count * 2
					end
				end
			end
			
			local side = UnitDefs[unitDefID].name:sub(1,2) -- send dropship of correct side
			GG.DropshipDelivery(unitID, teamID, side .. "_dropship", orderQueue, cost, "BB_Reinforcements_Inbound_ETA_30", DROPSHIP_DELAY)
			Spring.SendMessageToTeam(teamID, "Sending purchase order for the following:")
			for i, order in ipairs(orderQueue) do
				for orderDefID, count in pairs(order) do
					Spring.SendMessageToTeam(teamID, UnitDefs[orderDefID].name .. ":\t" .. count)
				end
			end
			ResetBuildQueue(unitID)
			orderCosts[unitID] = 0
			orderSizes[unitID] = 0
			SendButtonCoolDown(unitID, teamID)
			return true
		end
	end
	return true
end

function gadget:AllowUnitBuildStep(builderID, builderTeam, unitID, unitDefID, part)
	local builderDefID = Spring.GetUnitDefID(builderID)
	local builderDef = UnitDefs[builderDefID]
	if builderDef.name:find("dropzone") then
		return false
	end
	return true -- beacons!
end

function LanceControl(teamID, add)
	if add and teamSlotsRemaining[teamID] <= 8 then
		teamSlotsRemaining[teamID] = teamSlotsRemaining[teamID] + 4
	else -- lost a C3
		-- TODO: if numCombatUnits > numSlots then loss of control over lances etc
		-- check if there were any backup C3 towers
		local C3count = Spring.GetTeamUnitDefCount(teamID, C3_ID) -- TODO: cache
		if C3count < 2 then -- team lost control of / capacity for a lance
			teamSlotsRemaining[teamID] = teamSlotsRemaining[teamID] - 4
		end
	end
end
GG.LanceControl = LanceControl

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local unitDef = UnitDefs[unitDefID]
	if unitDef.name:find("dropzone") then
		ClearBuildOptions(unitID, true)
		AddBuildMenu(unitID)
		dropZones[unitID] = teamID
		teamDropZones[teamID] = unitID
	else
		local currSlots = teamSlotsRemaining[teamID]
		local unitType = unitTypes[unitDefID]
		if unitType then
			if unitType:find("mech") then
				teamSlotsRemaining[teamID] = currSlots - 1
			else -- any other combat unit is worth 1/2 a slot
				teamSlotsRemaining[teamID] = currSlots - 0.5
			end
		end
	end
end

function gadget:UnitDamaged(unitID, unitDefID, teamID, damage, paralyzer, weaponID,  projectileID, attackerID, attackerDefID, attackerTeam)
	if not modOptions or modOptions.income == "default" then
		if attackerID and attackerTeam and not AreTeamsAllied(teamID, attackerTeam) then
			AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if dropZones[unitID] then -- dropZone switched
		dropZones[unitID] = nil
		teamDropZones[teamID] = nil
	elseif unitDefID == C3_ID then
		LanceControl(teamID, false)
	end
	if not modOptions or modOptions.income == "default" then
		if attackerID and not AreTeamsAllied(teamID, attackerTeam) then
			AddTeamResource(attackerTeam, "metal", UnitDefs[unitDefID].metalCost * KILL_REWARD_MULT)
		end
	end
	-- reimburse 'weight'
	AddTeamResource(teamID, "energy", UnitDefs[unitDefID].energyCost)
	local currSlots = teamSlotsRemaining[teamID]
	local unitType = unitTypes[unitDefID]
	if unitType then
		if unitType:find("mech") then
			teamSlotsRemaining[teamID] = currSlots + 1
		else -- any other combat unit is worth 1/2 a slot
			teamSlotsRemaining[teamID] = currSlots + 0.5
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	-- reimburse 'weight'
	local weight = UnitDefs[unitDefID].energyCost
	AddTeamResource(oldTeam, "energy", weight)
	UseTeamResource(newTeam, "energy", weight)
end

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		local basicType = cp.unittype
		if basicType == "mech" then
			-- sort into light, medium, heavy, assault
			local mass = unitDef.mass
			local light = mass < 40 * 100
			local medium = not light and mass < 60 * 100
			local heavy = not light and not medium and mass < 80 * 100
			local assault = not light and not medium and not heavy
			local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
			unitTypes[unitDefID] = weight .. "mech"
		elseif basicType == "vehicle" then
			-- sort into vehicle, vtol, aero
			local vtol = unitDef.hoverAttack
			local aero = unitDef.canFly and not vtol
			unitTypes[unitDefID] = vtol and "vtol" or aero and "aero" or "vehicle"
		end
	end
	GG.Lances = {}
	for _, teamID in pairs(Spring.GetTeamList()) do
		GG.Lances[teamID] = 1
		teamSlotsRemaining[teamID] = 4
	end
end

function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		for _, teamID in pairs(Spring.GetTeamList()) do
			AddTeamResource(teamID, "metal", 50)
		end
		-- check if orders are still too expensive
		for unitID, teamID in pairs(dropZones) do
			CheckBuildOptions(unitID, teamID, GetTeamResources(teamID, "metal") - (orderCosts[unitID] or 0))
		end
		-- reduce cooldown timers
		for teamID, enableFrame in pairs(coolDowns) do
			local framesRemaining = enableFrame - n
			local unitID = teamDropZones[teamID]
			if framesRemaining > 0 then
				local minutes, seconds = GG.FramesToMinutesAndSeconds(framesRemaining)
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = true, name = minutes .. ":" .. seconds})
			else
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = false, name = "Submit \nOrder "})
				coolDowns[teamID] = nil
			end
		end
	end
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


end
