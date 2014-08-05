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

local modOptions = Spring.GetModOptions()

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
local EMPTY_TABLE = {} -- keep as empty
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local CBILLS_PER_SEC = (modOptions and tonumber(modOptions.income)) or 200
local BEACON_ID = UnitDefNames["beacon"].id
local C3_ID = UnitDefNames["upgrade_c3array"].id

local DROPSHIP_COOLDOWN = 30 * 30 -- 30s, time before the dropship has regained orbit, refuelled etc ready to drop again
local DROPSHIP_DELAY = 2 * 30 -- 2s, time taken to arrive on the map from SPACE!
local DAMAGE_REWARD_MULT = (modOptions and tonumber(modOptions.income_damage)) or 0.2
local KILL_REWARD_MULT = 0.0

-- local NUM_ICONS_PER_PAGE = 3 * 8
	
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local sendOrderCmdDesc = {
	id = CMD_SEND_ORDER,
	type   = CMDTYPE.ICON,
	name   = "Submit \nOrder ",
	action = 'submit_order',
	tooltip = "Submit your purchasing order",
}
local CMD_RUNNING_TOTAL = GG.CustomCommands.GetCmdID("CMD_RUNNING_TOTAL")
local runningTotalCmdDesc = {
	id = CMD_RUNNING_TOTAL,
	type   = CMDTYPE.ICON,
	name   = "Order C-Bills: \n0",
	disabled = true,
}
local CMD_RUNNING_TONS = GG.CustomCommands.GetCmdID("CMD_RUNNING_TONS")
local runningTonsCmdDesc = {
	id = CMD_RUNNING_TONS,
	type   = CMDTYPE.ICON,
	name   = "Order Tonnes: \n0",
	disabled = true,
}

-- Variables
local typeStrings = {"lightmech", "mediummech", "heavymech", "assaultmech", "vehicle", "vtol", "aero"}
local typeStringAliases = { -- whitespace is to try and equalise resulting font size
	["lightmech"] 	= "Light     \nMechs", 
	["mediummech"] 	= "Medium  \nMechs", 
	["heavymech"] 	= "Heavy    \nMechs", 
	["assaultmech"] = "Assault  \nMechs", 
	["vehicle"] 	= "Vehicles ", 
	["vtol"] 		= "VTOL     ",
	["aero"]		= "Aero     ",
}
local menuCmdDescs = {}
local menuCmdIDs = {}
for i, typeString in ipairs(typeStrings) do
	local cmdID = GG.CustomCommands.GetCmdID("CMD_MENU_" .. typeString:upper())
	menuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = typeStringAliases[typeString], -- TODO: texture?
		action = 'menu' .. typeString,
		tooltip = "Purchase " .. typeString,
	}
	menuCmdIDs[cmdID] = typeString
end

local unitTypes = {} -- unitTypes[unitDefID] = "lightmech" etc from typeStrings
local orderCosts = {} -- orderCosts[unitID] = cost
local orderTons = {} -- orderTons[unitID] = totalTonnage
local orderSizes = {} -- orderSizes[unitID] = size
local orderSizesPending = {} -- orderSizesPending[unitID] = size -- used to track slots of untis pending arrival

local dropZones = {} -- dropZones[unitID] = teamID
local teamDropZones = {} -- teamDropZone[teamID] = unitID
local C3Status = {} -- C3Status[unitID] = bool deployed
local teamC3Counts = {} -- teamC3Counts[teamID] = number
local dropShipStatus = {} -- dropShipStatus[teamID] = number, where 0 = Ready, 1 = Active, 2 = Cooldown
local orderStatus = {} -- orderStatus[teamID] = number, where 0 = Ready for a new order, 1 = order submitted, 2 = can't submit atm?

-- teamSlots[teamID] = {[1] = {active = true, used = number_used, available = number_available, units = {unitID1 = tons, unitID2 = tons, ...}}, ...}
local teamSlots = {}
local unitLances = {} -- unitLances[unitID] = group_number

for _, teamID in pairs(Spring.GetTeamList()) do
	teamSlots[teamID] = {}
	teamC3Counts[teamID] = 0
	for i = 1, 3 do
		teamSlots[teamID][i] = {}
		teamSlots[teamID][i].active = i == 1
		teamSlots[teamID][i].used = 0
		teamSlots[teamID][i].available = 4
		teamSlots[teamID][i].units = {}
	end
end

local function TeamSlotsRemaining(teamID)
	local slots = 0
	for i = 1, 3 do
		-- we only want to consider slots in lances we actively control... 
		-- ...and only whole slots should be counted (can't split a mech across 2x 0.5 slots!)
		slots = slots + ((teamSlots[teamID][i].active and math.floor(teamSlots[teamID][i].available)) or 0)
	end
	return slots
end

local function TeamAvailableGroup(teamID, size)
	for i = 1, 3 do
		if teamSlots[teamID][i].available >= size then return i, teamSlots[teamID][i].active end
	end
	return false
end

local function ToggleLink(unitID, teamID, lost, tonnage)
	if lost then
		Spring.SetUnitNoSelect(unitID, true)
		AddTeamResource(teamID, "energy", tonnage)
		Spring.SetUnitRulesParam(unitID, "LOST_LINK", 1)
	else
		Spring.SetUnitNoSelect(unitID, false)
		UseTeamResource(teamID, "energy", tonnage)
		Spring.SetUnitRulesParam(unitID, "LOST_LINK", 0)
	end
end

function LanceControl(teamID, unitID, add)
	if teamID == GAIA_TEAM_ID then return end -- no need to track for gaia
	if add then
		C3Status[unitID] = true
		teamC3Counts[teamID] = teamC3Counts[teamID] + 1
		AddTeamResource(teamID, "energy", 200)
		--Spring.Echo(teamID, "C3 Count INCREASE", teamC3Counts[teamID])
		if teamC3Counts[teamID] <= 2 then -- only the first 2 C3s give you an extra lance
			local newLance = teamC3Counts[teamID] + 1
			Spring.SendMessageToTeam(teamID, "Gained lance #" .. newLance)
			Spring.SetTeamRulesParam(teamID, "LANCES", newLance)
			local groupSlots = teamSlots[teamID][newLance]
			groupSlots.active = true
			-- If there were any mechs in this lance, make them selectable again
			for unitID, tonnage in pairs(groupSlots.units) do
				ToggleLink(unitID, teamID, false, tonnage)
			end
		end
	elseif C3Status[unitID] then -- lost a deployed C3
		teamC3Counts[teamID] = teamC3Counts[teamID] - 1
		-- When you gain a C3 you get 200 extra e, when you lose one, you lose 200 storage... 
		-- ..but Spring helpfully fills it with all that extra e, screwing the tonnage system
		-- So remove the extra tonnage manually
		UseTeamResource(teamID, "energy", 200)
		-- check if there were any backup C3 towers
		--Spring.Echo(teamID, "C3 Count DECREASE", teamC3Counts[teamID])
		if teamC3Counts[teamID] < 2 then -- team lost control of / capacity for a lance
			local lostLance = teamC3Counts[teamID] + 2
			Spring.SendMessageToTeam(teamID, "Lost lance #" .. lostLance)
			Spring.SetTeamRulesParam(teamID, "LANCES", lostLance)
			local groupSlots = teamSlots[teamID][lostLance]
			groupSlots.active = false
			-- stop any mechs in this lance and make them unselectable
			Spring.GiveOrderToUnitMap(groupSlots.units, CMD.STOP, EMPTY_TABLE, EMPTY_TABLE)
			for unitID, tonnage in pairs(groupSlots.units) do
				ToggleLink(unitID, teamID, true, tonnage)
			end
		end
	end
end
GG.LanceControl = LanceControl

local function UpdateTeamSlots(teamID, unitID, unitDefID, add)
	if select(3,Spring.GetTeamInfo(teamID)) or teamID == GAIA_TEAM_ID then return end -- team died
	local ud = UnitDefs[unitDefID]
	local slotChange = ((ud.customParams.unittype == "mech" or ud.canFly) and 1) or 0.5
	if add then -- new unit
		local dz = teamDropZones[teamID]
		if dz then
			orderSizesPending[dz] = orderSizesPending[dz] - slotChange
			--if orderSizesPending[dz] < 0 then Spring.Echo(teamID, "ORDER SIZES NEGATIVE L213", orderSizesPending[dz]) end
		end
		-- Deduct weight from current tonnage limit
		UseTeamResource(teamID, "energy", ud.energyCost)
		local group, active = TeamAvailableGroup(teamID, slotChange)
		if group then
			if not active then 
				--Spring.Echo(teamID, "Assigned to an inactive group!") 
				ToggleLink(unitID, teamID, true, ud.energyCost)
			end
			unitLances[unitID] = group
			SendToUnsynced("LANCE", teamID, unitID, group)
			local groupSlots = teamSlots[teamID][group]
			groupSlots.used = groupSlots.used + slotChange
			groupSlots.available = groupSlots.available - slotChange
			groupSlots.units[unitID] = ud.energyCost
		else 
			Spring.Echo(teamID, "FLOZi logic fail: No available group", TeamSlotsRemaining(teamID), slotChange, ud.name) 
		end
	else -- unit died
		-- reimburse 'weight'
		AddTeamResource(teamID, "energy", ud.energyCost)
		local group = unitLances[unitID]
		local groupSlots = teamSlots[teamID][group]
		--if not teamID or not group then Spring.Echo("UHOH!", teamID, group) return end
		groupSlots.used = groupSlots.used - slotChange
		groupSlots.available = groupSlots.available + slotChange
		groupSlots.units[unitID] = nil
		unitLances[unitID] = nil
	end
	Spring.SetTeamRulesParam(teamID, "TEAM_SLOTS_REMAINING", TeamSlotsRemaining(teamID))
end

GG.TeamSlotsRemaining = TeamSlotsRemaining

local function AddBuildMenu(unitID)
	InsertUnitCmdDesc(unitID, sendOrderCmdDesc)
	InsertUnitCmdDesc(unitID, runningTotalCmdDesc)
	InsertUnitCmdDesc(unitID, runningTonsCmdDesc)
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
	orderSizesPending[unitID] = 0
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
		GG.Delay.DelayCall(Spring.GiveOrderToUnit,{unitID, CMD.REMOVE, {order.tag}, {"ctrl"}},1)
	end
end

local function CheckBuildOptions(unitID, teamID, money, weightLeft, cmdID)
	--local weightLeft = GetTeamResources(teamID, "energy")
	local cmdDescs = GetUnitCmdDescs(unitID) or EMPTY_TABLE
	for cmdDescID = 1, #cmdDescs do
		local buildDefID = cmdDescs[cmdDescID].id
		local cmdDesc = cmdDescs[cmdDescID]
		if cmdDesc.id ~= cmdID and buildDefID < 0 then
			local currParam = cmdDesc.params[1] or ""
			local cCost, tCost
			if buildDefID < 0 then -- a build order
				cCost = UnitDefs[-buildDefID].metalCost
				tCost = UnitDefs[-buildDefID].energyCost
				if UnitDefs[-buildDefID].customParams.unittype == "vehicle" then
					tCost = tCost * 2
				end
			else
				cCost = GG.CommandCosts[buildDefID] or 0 -- TODO: the intention was to disable e.g. Orbital Strike if you can't afford it
				tCost = 0
			end
			if buildDefID < 0 and TeamSlotsRemaining(teamID) <= 0.5 then -- builder order but no team slots left
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"L"}})
			elseif cCost > 0 and (TeamSlotsRemaining(teamID) - (orderSizes[teamID] or 0)) < 1 and (currParam == "C" or currParam == "" or currParam == "L") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"L"}})
			elseif cCost > money and (currParam == "" or currParam == "C") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"C"}})
			elseif tCost > weightLeft and (currParam == "" or currParam == "T") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"T"}})
			else
				if cmdDesc.disabled and (currParam == "C" or currParam == "T" or currParam == "L") then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = EMPTY_TABLE})
				end
			end
		end
	end
end

local coolDowns = {} -- coolDowns[teamID] = enableFrame
GG.coolDowns = coolDowns

function UpdateButtons(teamID)
	local unitID = teamDropZones[teamID]
	if orderStatus[teamID] == 0 then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = false, name = "Submit \nOrder "})
		if orderSizes[teamID] == 0 then
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = "Order C-Bills: \n0"})
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = "Order Tonnes: \n0"})
		end
	elseif orderStatus[teamID] == 1 then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {--[[disabled = false, ]]name = "Order \nSent "})
	end
	--coolDowns[teamID] = math.huge -- TODO: allow orders when ACTIVE? -> will be corrected when the dropship leave
end

-- TODO: Issues if dropzone is 'flipped' to another beacon
function DropshipLeft(teamID) -- called by Dropship once it has left, to enable "Submit Order"
	local unitID = teamDropZones[teamID]
	orderStatus[teamID] = 0
	if unitID then -- dropzone might have died in the meantime
		UpdateButtons(teamID)
	end
	-- Dropship is no longer ACTIVE, it is entering COOLDOWN
	GG.PlaySoundForTeam(teamID, "BB_Reinforcements_Inbound_ETA_30", 1)
	dropShipStatus[teamID] = 2
	local enableFrame = GetGameFrame() + DROPSHIP_COOLDOWN
	coolDowns[teamID] = enableFrame
	Spring.SetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN", enableFrame) -- frame this team can call dropship again
end
GG.DropshipLeft = DropshipLeft

-- Factories can't implement gadget:CommandFallback, so fake it ourselves
local function SendCommandFallback(unitID, unitDefID, teamID)
	if orderStatus[teamID] == 0 then return end -- order was cancelled
	if dropShipStatus[teamID] == 0 then -- Dropship is READY
		-- CALL DROPSHIP
		local orderQueue = Spring.GetFullBuildQueue(unitID)
		for i, order in pairs(orderQueue) do -- we need to double all orders for vehicles
			for orderDefID, count in pairs(order) do
				if unitTypes[orderDefID] == "vehicle" then -- TODO: vtol and aero?
					orderQueue[i][orderDefID] = count * 2
				end
			end
		end
		
		local side = UnitDefs[unitDefID].name:sub(1,2) -- send dropship of correct side
		-- TODO: Sound needs to change?
		-- TODO: Remove the 3 second delay here? causes a bug where you can quickly cancel to get refund & units, and feels 'laggy'
		GG.DropshipDelivery(unitID, teamID, side .. "_dropship", orderQueue, 0, nil, DROPSHIP_DELAY)
		Spring.SendMessageToTeam(teamID, "Sending purchase order for the following:")
		for i, order in ipairs(orderQueue) do
			for orderDefID, count in pairs(order) do
				Spring.SendMessageToTeam(teamID, UnitDefs[orderDefID].name .. ":\t" .. count)
			end
		end
		ResetBuildQueue(unitID)
		orderCosts[unitID] = 0
		orderTons[unitID] = 0
		orderSizesPending[unitID] = orderSizes[unitID]
		--if orderSizesPending[unitID] < 0 then Spring.Echo(teamID, "ORDER SIZES NEGATIVE L377", orderSizesPending[unitID]) end
		orderSizes[unitID] = 0
		-- Dropship can now be considered ACTIVE even though it hasn't arrived yet
		dropShipStatus[teamID] = 1
	else -- Dropship is ACTIVE or COOLDOWN
		GG.Delay.DelayCall(SendCommandFallback, {unitID, unitDefID, teamID}, 16)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitTypes[unitDefID] then -- strictly no commands to lost link units
		local group = unitLances[unitID]
		local groupSlots = teamSlots[teamID][group]
		if groupSlots then return groupSlots.active else return true end
	end
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
			
			local unitDef = UnitDefs[-cmdID]
			local cost = unitDef.metalCost
			local weight = (unitDef.customParams.unittype == "vehicle" and not unitDef.canFly) and 2 * unitDef.energyCost or unitDef.energyCost -- vehicles come in pairs
			local runningTotal = orderCosts[unitID] or 0
			local runningTons = orderTons[unitID] or 0
			local runningSize = orderSizes[unitID] or 0
			local money = GetTeamResources(teamID, "metal")
			local tonnage = GetTeamResources(teamID, "energy")
			if not rightClick then
				if cmdOptions.shift or cmdOptions.ctrl then return false end -- otherwise we can (dramatically) circumvent unit limits
				if (TeamSlotsRemaining(teamID) - orderSizesPending[unitID] - runningSize) < 1 then 
					return false 
				end -- <1 as may be 0.5, but _ordering_ is always 1
				local newTotal = runningTotal + cost
				local newTons = runningTons + weight
				if  newTotal < money and newTons < tonnage then -- check we can afford it
					Spring.SendMessageToTeam(teamID, "Running C-Bills: " .. newTotal)
					Spring.SendMessageToTeam(teamID, "Running Tonnage: " .. newTons)
					orderCosts[unitID] = newTotal
					orderTons[unitID] = newTons
					orderSizes[unitID] = runningSize + 1
					CheckBuildOptions(unitID, teamID, money - (newTotal), tonnage - (newTons), cmdID)
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = "Order C-Bills: \n" .. newTotal})
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = "Order Tonnes: \n" .. newTons})
					--Spring.Echo(teamID, "SLOTS", TeamSlotsRemaining(teamID), orderSizesPending[unitID], runningSize)
					return true
				else
					--Spring.Echo("not enough money")
					return false -- not enough money
				end
			elseif runningSize > 0 then  -- only allow removal if order contains units (prevent -ve running totals!)
				local cmdDesc = GetUnitCmdDescs(unitID, FindUnitCmdDesc(unitID, cmdID))[1] -- TODO: This is just awful
				local currNumber = tonumber(cmdDesc.params[1]) or 0
				if currNumber > 0 then -- only allow if more than 1 of **this** unit currently on order
					orderCosts[unitID] = runningTotal - cost
					orderTons[unitID] = runningTons - weight
					orderSizes[unitID] = runningSize - 1
					CheckBuildOptions(unitID, teamID, money - (runningTotal - cost), tonnage - (runningTons - weight))
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = "Order C-Bills: \n" .. runningTotal - cost})
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = "Order Tonnes: \n" .. runningTons - weight})
					return true
				else
					return false
				end
			end
			
		elseif cmdID == CMD_SEND_ORDER then
			local money = GetTeamResources(teamID, "metal")
			local cost = orderCosts[unitID] or 0
			if rightClick and orderStatus[teamID] == 1 then
				-- cancelling the order, refund the cost and update the buttons
				orderStatus[teamID] = 0
				AddTeamResource(teamID, "metal", cost)
				UpdateButtons(teamID)
				return true
			elseif orderStatus[teamID] == 1 then
				return false -- we already have submitted an order and not cancelled it
			end
			if (orderSizes[unitID] or 0) == 0 then return false end -- don't allow empty orders
			-- check we can afford the order; possible that a previously affordable order is now too much e.g. if towers have been purchased
			-- N.B. It should not be possible for available tonnage to change between orders, so we don't need to check that
			if cost > money then return false end
			-- We are going ahead with this order. Deduct the cost now.
			UseTeamResource(teamID, "metal", cost)
			orderStatus[teamID] = 1
			UpdateButtons(teamID)
			GG.Delay.DelayCall(SendCommandFallback, {unitID, unitDefID, teamID}, 16)
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

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local unitDef = UnitDefs[unitDefID]
	if unitDef.name:find("dropzone") then
		ClearBuildOptions(unitID, true)
		AddBuildMenu(unitID)
		dropZones[unitID] = teamID
		teamDropZones[teamID] = unitID
	elseif UnitDefs[unitDefID].customParams.dropship == "union" then -- TODO: This is dreadful
		if Spring.ValidUnitID(teamDropZones[teamID]) then -- even worse
			EditUnitCmdDesc(teamDropZones[teamID], FindUnitCmdDesc(teamDropZones[teamID], CMD_SEND_ORDER), {disabled = true, name = "Dropship \nArrived "})
		end
	elseif unitTypes[unitDefID] then
		UpdateTeamSlots(teamID, unitID, unitDefID, true)
	end
end


local WALL_ID = UnitDefNames["wall"].id
local GATE_ID = UnitDefNames["wall_gate"].id

function gadget:UnitDamaged(unitID, unitDefID, teamID, damage, paralyzer, weaponID,  projectileID, attackerID, attackerDefID, attackerTeam)
	if attackerID and attackerTeam and not AreTeamsAllied(teamID, attackerTeam) and unitDefID ~= WALL_ID and unitDefID ~= GATE_ID then
		AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if dropZones[unitID] then -- dropZone switched
		dropZones[unitID] = nil
		teamDropZones[teamID] = nil
	elseif unitDefID == C3_ID then
		LanceControl(teamID, unitID, false)
		C3Status[unitID] = nil
	end
	if attackerID and not AreTeamsAllied(teamID, attackerTeam) and unitDefID ~= WALL_ID and unitDefID ~= GATE_ID then
		AddTeamResource(attackerTeam, "metal", UnitDefs[unitDefID].metalCost * KILL_REWARD_MULT)
	end
	if unitTypes[unitDefID] then
		UpdateTeamSlots(teamID, unitID, unitDefID, false)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
	if newTeam ~= GAIA_TEAM_ID then
		gadget:UnitCreated(unitID, unitDefID, newTeam)
		if unitDefID == C3_ID then
			LanceControl(newTeam, unitID, true)
		end
	end
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
	for _, teamID in pairs(Spring.GetTeamList()) do
		dropShipStatus[teamID] = 0
		orderStatus[teamID] = 0
	end
end

function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		for _, teamID in pairs(Spring.GetTeamList()) do
			AddTeamResource(teamID, "metal", CBILLS_PER_SEC)
		end
		-- check if orders are still too expensive
		for unitID, teamID in pairs(dropZones) do
			local cBills = GetTeamResources(teamID, "metal") - (orderCosts[unitID] or 0)
			local tonnage = GetTeamResources(teamID, "energy") - (orderTons[unitID] or 0)
			CheckBuildOptions(unitID, teamID, cBills, tonnage)
		end
		-- reduce cooldown timers
		for teamID, enableFrame in pairs(coolDowns) do
			local framesRemaining = enableFrame - n
			local unitID = teamDropZones[teamID]
			if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then -- check valid first (lazy evaluation means non-valid unitID is then not passed)
				coolDowns[teamID] = -1
			else
				if framesRemaining <= 0 and dropShipStatus[teamID] > 0 then
					coolDowns[teamID] = -2
					-- dropship is now READY
					dropShipStatus[teamID] = 0
				end
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

local MY_TEAM_ID = Spring.GetMyTeamID()

function AddUnitToLance(eventID, teamID, unitID, group)
	if teamID == MY_TEAM_ID then
		CallAsTeam(teamID, Spring.SetUnitGroup, unitID, group)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("LANCE", AddUnitToLance)
end

end
