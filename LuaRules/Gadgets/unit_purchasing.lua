function gadget:GetInfo()
	return {
		name		= "Purchasing",
		desc		= "Controls purchasing abilities",
		author		= "FLOZi (C. Lawrence)",
		date		= "31/08/13",
		license 	= "GNU GPL v2",
		layer		= 3, -- must come after game_spawn
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
local CBILLS_PER_SEC = (modOptions and tonumber(modOptions.income)) or 10
local BEACON_ID = UnitDefNames["beacon"].id
local C3_ID = UnitDefNames["upgrade_c3array"].id

--local DROPSHIP_COOLDOWN = 30 * 30 -- 30s, time before the dropship has regained orbit, refuelled etc ready to drop again
local DROPSHIP_DELAY = 2 * 30 -- 2s, time taken to arrive on the map from SPACE!
local DAMAGE_REWARD_MULT = (modOptions and tonumber(modOptions.income_damage)) or 0.1
Spring.SetGameRulesParam("damage_reward_mult", DAMAGE_REWARD_MULT)
local INSURANCE_MULT = (modOptions and tonumber(modOptions.insurance)) or 0.1
Spring.SetGameRulesParam("insurance_mult", INSURANCE_MULT)

--local KILL_REWARD_MULT = 0.0
-- local NUM_ICONS_PER_PAGE = 3 * 8

local SELL_DISTANCE = 460 -- TODO: flagCapradius, grab from GG or game rules?
local CMD_SELL = GG.CustomCommands.GetCmdID("CMD_SELL")
local sellOrderCmdDesc = {
	id = CMD_SELL,
	type   = CMDTYPE.ICON,
	name   = "  Sell   \n  Unit  ",
	action = 'sell_mech',
	tooltip = "Calls a dropship to sell the unit (75% return)",
}
	
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
local ignoredCmdDescs = {CMD_SEND_ORDER = true, CMD_RUNNING_TOTAL = true, CMD_RUNNING_TONS = true}

-- Variables
local typeStrings = {"lightmech", "mediummech", "heavymech", "assaultmech"}--, "vehicle", "vtol", "aero"}
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
local dropShipTypes = {} -- dropShipTypes[unitDefID] = "mech", "vehicle" or "upgrade"
local unitSlotChanges = {} -- unitSlotChanges = 1 or 0.5

local orderCosts = {} -- orderCosts[unitID] = cost
local orderTons = {} -- orderTons[unitID] = totalTonnage
local orderSizes = {} -- orderSizes[unitID] = size
local orderSizesPending = {} -- orderSizesPending[unitID] = size -- used to track slots of untis pending arrival

local dropZones = {} -- dropZones[unitID] = teamID
local teamDropZones = {} -- teamDropZone[teamID] = unitID
local teamDropShipTypes = {} -- teamDropShipTypes[teamID] = {tier = 1 or 2 or 3, def = unitDefID}
local C3Status = {} -- C3Status[unitID] = bool deployed
local teamC3Counts = {} -- teamC3Counts[teamID] = number
local dropShipStatus = {} -- dropShipStatus[teamID] = number, where 0 = Ready, 1 = Active, 2 = Cooldown
local orderStatus = {} -- orderStatus[teamID] = number, where 0 = Ready for a new order, 1 = order submitted, 2 = can't submit atm?

-- teamSlots[teamID] = {[1] = {active = true, used = number_used, available = number_available, units = {unitID1 = tons, unitID2 = tons, ...}}, ...}
local teamSlots = {}
local unitLances = {} -- unitLances[unitID] = group_number

local function TeamDropshipUpgrade(teamID)
	local side = GG.teamSide[teamID]
	local oldDefID = teamDropShipTypes[teamID].def
	local newTier = teamDropShipTypes[teamID].tier + 1
	if newTier <= #(GG.dropShipProgression) then -- another tier is available beyond what we currently have
		local newDefID = UnitDefNames[side .. "_dropship_" .. GG.dropShipProgression[newTier]].id
		teamDropShipTypes[teamID] = {def = newDefID, tier = newTier}
		local maxTonnage = UnitDefs[newDefID].customParams.maxtonnage
		local tonnageIncrease = maxTonnage - UnitDefs[oldDefID].customParams.maxtonnage
		Spring.SetTeamResource(teamID, "es", maxTonnage)
		Spring.AddTeamResource(teamID, "e", tonnageIncrease)
	else -- max upgrade reached, disable button
		Spring.SendMessageToTeam(teamID, "Dropship Fully Upgraded!")
	end
end
GG.TeamDropshipUpgrade = TeamDropshipUpgrade

local function TeamSlotsRemaining(teamID)
	local slots = 0
	for i = 1, 3 do
		-- we only want to consider slots in lances we actively control... 
		-- ...and only whole slots should be counted (can't split a mech across 2x 0.5 slots!)
		slots = slots + ((teamSlots[teamID][i].active and math.floor(teamSlots[teamID][i].available)) or 0)
	end
	return slots
end
GG.TeamSlotsRemaining = TeamSlotsRemaining

local function TeamAvailableGroup(teamID, size)
	if select(3, Spring.GetTeamInfo(teamID)) then return false end -- team died
	if teamID == GAIA_TEAM_ID then return false end
	for i = 1, 3 do
		if teamSlots[teamID][i].available == nil or size == nil then Spring.Echo("FLOZi Logic Fail", teamSlots[teamID][i].available, size) return false end
		if teamSlots[teamID][i].available >= size then return i, teamSlots[teamID][i].active end
	end
	return false
end

local function ToggleLink(unitID, teamID, lost)
	if lost then
		SendToUnsynced("TOGGLE_SELECT", unitID, teamID, false)
		Spring.SetUnitRulesParam(unitID, "LOST_LINK", 1, {inlos = true})
	else
		SendToUnsynced("TOGGLE_SELECT", unitID, teamID, true)
		Spring.SetUnitRulesParam(unitID, "LOST_LINK", 0, {inlos = true})
	end
end

function TonnageSort(a, b)
	return a.tonnage > b.tonnage
end

local function AssignGroup(unitID, unitDefID, teamID, slotChange, group)
	local groupSlots = teamSlots[teamID][group]
	groupSlots.used = groupSlots.used + slotChange
	groupSlots.available = groupSlots.available - slotChange
	if slotChange > 0 then -- adding a unit to group
		unitLances[unitID] = group
		SendToUnsynced("LANCE", teamID, unitID, group)
		groupSlots.units[unitID] = UnitDefs[unitDefID].energyCost
	else -- removing a unit from a group
		groupSlots.units[unitID] = nil
		unitLances[unitID] = nil
		-- iterate through existing link lost mechs to see if they will fit into this group (TODO: tonnage also an issue)
		local candidates = {}
		local numCandidates = 0
		for groupNum, currGroupSlots in ipairs(teamSlots[teamID]) do
			-- lance is higher than the one that lost a unit
			-- AND it has units assigned to it
			-- AND the team has inssufficient C3's to support it
			if groupNum > group and currGroupSlots.used > 0 and (teamC3Counts[teamID] + 1) < groupNum then
				for groupUnitID, tonnage in pairs(currGroupSlots.units) do
					local linkLost = (Spring.GetUnitRulesParam(groupUnitID, "LOST_LINK") or 0) == 1
					if linkLost then
						numCandidates = numCandidates + 1
						candidates[groupUnitID] = {id = groupUnitID, tonnage = tonnage}
						--[[if numCandidates == groupSlots.available then
							break -- no point continuing if we already have enough mechs to fill the lance
						end]]
					end
				end
			end
		end
		-- TODO: Probably a FILO queue is better here?
		-- sort by tonnage (descending)
		table.sort(candidates, TonnageSort)
		-- we don't want to change the list as we iterate over it so build a list of candidates first then iterate over that making the changes
		-- use a first-fit decreasing bin packing algorithm
		local tonnageAvailable = Spring.GetTeamResources(teamID, "energy")
		local numAssigned = 0
		for i, candidate in pairs(candidates) do
			if numAssigned < groupSlots.available then -- unit will fit
				unitLances[candidate.id] = group
				ToggleLink(candidate.id, teamID, false)
				SendToUnsynced("LANCE", teamID, candidate.id, group)
				numAssigned = numAssigned + 1
			end
		end
	end
end

function LanceControl(teamID, unitID, add)
	if teamID == GAIA_TEAM_ID then return end -- no need to track for gaia
	if add then
		C3Status[unitID] = true
		teamC3Counts[teamID] = teamC3Counts[teamID] + 1
		AddTeamResource(teamID, "energy", UnitDefs[C3_ID].energyStorage)
		--Spring.Echo(teamID, "C3 Count INCREASE", teamC3Counts[teamID])
		if teamC3Counts[teamID] <= 2 then -- only the first 2 C3s give you an extra lance
			local newLance = teamC3Counts[teamID] + 1
			Spring.SendMessageToTeam(teamID, "Gained lance #" .. newLance)
			Spring.SetTeamRulesParam(teamID, "LANCES", newLance)
			local groupSlots = teamSlots[teamID][newLance]
			groupSlots.active = true
			-- If there were any mechs in this lance, make them selectable again
			for unitID in pairs(groupSlots.units) do
				ToggleLink(unitID, teamID, false)
			end
		end
	elseif C3Status[unitID] then -- lost a deployed C3
		teamC3Counts[teamID] = teamC3Counts[teamID] - 1
		-- check if there were any backup C3 towers
		--Spring.Echo(teamID, "C3 Count DECREASE", teamC3Counts[teamID])
		if teamC3Counts[teamID] < 2 then -- team lost control of / capacity for a lance
			local lostLance = teamC3Counts[teamID] + 2
			Spring.SendMessageToTeam(teamID, "Lost lance #" .. lostLance)
			Spring.SetTeamRulesParam(teamID, "LANCES", lostLance)
			local groupSlots = teamSlots[teamID][lostLance]
			groupSlots.active = false
			-- stop any mechs in this lance and make them unselectable
			--Spring.GiveOrderToUnitMap(groupSlots.units, CMD.STOP, EMPTY_TABLE, EMPTY_TABLE)
			for unitID, tonnage in pairs(groupSlots.units) do
				local unitDefID = Spring.GetUnitDefID(unitID)
				local slotChange = unitSlotChanges[unitDefID]
				local lowerGroup, lowerActive = TeamAvailableGroup(teamID, slotChange)
				if lowerGroup and lowerActive then -- if there is a slot lower down, take it
					-- cleanup old group
					AssignGroup(unitID, unitDefID, teamID, -slotChange, unitLances[unitID])
					-- add to new group
					AssignGroup(unitID, unitDefID, teamID, slotChange, lowerGroup)
				else -- otherwise we've lost the link
					ToggleLink(unitID, teamID, true, tonnage)
				end
			end
		end
		C3Status[unitID] = nil
	end
end
GG.LanceControl = LanceControl

local function UpdateTeamSlots(teamID, unitID, unitDefID, add)
	if select(3,Spring.GetTeamInfo(teamID)) or teamID == GAIA_TEAM_ID then return end -- team died
	local ud = UnitDefs[unitDefID]
	local slotChange = unitSlotChanges[unitDefID]
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
			AssignGroup(unitID, unitDefID, teamID, slotChange, group)
		else 
			Spring.Echo(teamID, "FLOZi logic fail: No available group", TeamSlotsRemaining(teamID), slotChange, ud.name) 
		end
	else -- unit died
		-- reimburse 'weight'
		AddTeamResource(teamID, "energy", ud.energyCost)
		local group = unitLances[unitID]
		AssignGroup(unitID, unitDefID, teamID, -slotChange, group)
	end
	Spring.SetTeamRulesParam(teamID, "TEAM_SLOTS_REMAINING", TeamSlotsRemaining(teamID))
end

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

local L = {"L"}
local C = {"C"}
local T = {"T"}

local function CheckBuildOptions(unitID, teamID, money, weightLeft, cmdID)
	--local weightLeft = GetTeamResources(teamID, "energy")
	local cmdDescs = GetUnitCmdDescs(unitID) or EMPTY_TABLE
	for cmdDescID = 1, #cmdDescs do
		local buildDefID = cmdDescs[cmdDescID].id
		local cmdDesc = cmdDescs[cmdDescID]
		if cmdDesc.id ~= cmdID and not ignoredCmdDescs[cmdID] then
			local currParam = cmdDesc.params[1] or ""
			local cCost, tCost
			if buildDefID < 0 then -- a build order
				cCost = UnitDefs[-buildDefID].metalCost
				tCost = UnitDefs[-buildDefID].energyCost
			else
				cCost = GG.CommandCosts[buildDefID] or 0 -- TODO: the intention was to disable e.g. Orbital Strike if you can't afford it
				tCost = 0
			end
			if buildDefID < 0 
			and (currParam == "C" or currParam == "" or currParam == "L")
			and (TeamSlotsRemaining(teamID) - (orderSizes[unitID] or 0) - (orderSizesPending[unitID] or 0)) < 1 then -- builder order but no team slots left
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = L})
			--[[elseif cCost > 0 and 
				(TeamSlotsRemaining(teamID) - (orderSizes[teamID] or 0) - (orderSizesPending[teamID] or 0)) < 1 and 
				(currParam == "C" or currParam == "" or currParam == "L") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = L})]]
			elseif cCost > money and (currParam == "" or currParam == "C") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = C})
			elseif tCost > weightLeft and (currParam == "" or currParam == "T") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = T})
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

function UpdateButtons(teamID) -- Toggles Submit Order vs Order Sent
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

function OrderFinished(unitID, teamID)
	ResetBuildQueue(unitID)
	orderCosts[unitID] = 0
	orderTons[unitID] = 0
	orderSizesPending[unitID] = orderSizes[unitID]
	--if orderSizesPending[unitID] < 0 then Spring.Echo(teamID, "ORDER SIZES NEGATIVE L377", orderSizesPending[unitID]) end
	orderSizes[unitID] = 0
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
	local dropShipDef = UnitDefs[teamDropShipTypes[teamID].def]
	local enableFrame = GetGameFrame() + dropShipDef.customParams.cooldown
	coolDowns[teamID] = enableFrame
	Spring.SetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN", enableFrame) -- frame this team can call dropship again
end
GG.DropshipLeft = DropshipLeft

-- Factories can't implement gadget:CommandFallback, so fake it ourselves
local function SendCommandFallback(unitID, unitDefID, teamID, cost)
	if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) then return false end -- unit died
	if orderStatus[teamID] == 0 then return end -- order was cancelled
	if dropShipStatus[teamID] == 0 then -- Dropship is READY
		local unitID = teamDropZones[teamID]
		if not unitID then -- Dropzone has died and not been replaced whilst order is due!
			AddTeamResource(teamID, "metal", cost) -- refund
		end
		-- CALL DROPSHIP
		local orderQueue = Spring.GetFullBuildQueue(unitID)
		if not orderQueue then return end -- dropzone died TODO: Transfer to new DZ if there is one
		if #orderQueue > 0 then -- proceed with order
			-- TODO: Sound needs to change?
			GG.DropshipDelivery(unitID, teamID, teamDropShipTypes[teamID].def, orderQueue, 0, nil, 0)
			Spring.SendMessageToTeam(teamID, "Sending purchase order for the following:")
			for i, order in ipairs(orderQueue) do
				for orderDefID, count in pairs(order) do
					Spring.SendMessageToTeam(teamID, UnitDefs[orderDefID].humanName .. ":\t" .. count)
				end
			end
			-- Dropship can now be considered ACTIVE even though it hasn't arrived yet
			dropShipStatus[teamID] = 1
		else -- cancelled
			AddTeamResource(teamID, "metal", cost)
			dropShipStatus[teamID] = 0
			orderStatus[teamID] = 0
			UpdateButtons(teamID)
		end
		-- clean up (regardless of whether or not order was fulfilled or cancelled)
		OrderFinished(unitID, teamID)
	else -- Dropship is ACTIVE or COOLDOWN
		GG.Delay.DelayCall(SendCommandFallback, {unitID, unitDefID, teamID, cost}, 16)
	end
end

local function SellUnit(unitID, unitDefID, teamID, unitType)
	Spring.SendMessageToTeam(teamID, "Selling " .. unitType .. "!")
	AddTeamResource(teamID, "metal", UnitDefs[unitDefID].metalCost * 0.75)
	-- TODO: wait around and get in dropship
	Spring.SetUnitRulesParam(unitID, "sold", 1)
	Spring.DestroyUnit(unitID, false, true)
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if unitTypes[unitDefID] then
		local group = unitLances[unitID]
		local groupSlots = teamSlots[teamID][group]
		if groupSlots then
			if not groupSlots.active then 
				return false -- strictly no commands to lost link units
			elseif cmdID == CMD_SELL then
				local dropZone = teamDropZones[teamID]
				if dropZone then
					local dist = Spring.GetUnitSeparation(unitID, dropZone)
					if dist < SELL_DISTANCE then
						SellUnit(unitID, unitDefID, teamID, "mech")
					else
						Spring.SendMessageToTeam(teamID, "Cannot sell mech; not within range of Dropzone!")
					end
				else
					Spring.SendMessageToTeam(teamID, "Cannot sell mech; you have no Dropzone!")
				end
			end
		end
		return true -- allow all other commands through here
	elseif dropZones[unitID] then
		local typeString = menuCmdIDs[cmdID]
		local rightClick = cmdOptions.right
		if typeString then
			ClearBuildOptions(unitID)
			ShowBuildOptionsByType(unitID, typeString)
			return true
		elseif cmdID < 0 then
			local unitDef = UnitDefs[-cmdID]
			local cost = unitDef.metalCost
			local weight = unitDef.energyCost
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
				if  newTotal <= money and newTons <= tonnage then -- check we can afford it
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
			if rightClick then
				if orderStatus[teamID] == 1 then
					-- cancelling the order, refund the cost and update the buttons
					orderStatus[teamID] = 0
					AddTeamResource(teamID, "metal", cost)
					UpdateButtons(teamID)
					return true
				else return false end
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
			GG.Delay.DelayCall(SendCommandFallback, {unitID, unitDefID, teamID, cost}, 16)
			return true
		end
	elseif GG.outpostDefs[unitDefID] then -- an upgrade
		if cmdID == CMD_SELL then
			SellUnit(unitID, unitDefID, teamID, "upgrade")
		else
			return true -- allow all other commands through here
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
	elseif dropShipTypes[unitDefID] == "mech" then
		if Spring.ValidUnitID(teamDropZones[teamID]) then -- TODO: (Why) is this even required?
			EditUnitCmdDesc(teamDropZones[teamID], FindUnitCmdDesc(teamDropZones[teamID], CMD_SEND_ORDER), {disabled = true, name = "Dropship \nArrived "})
		end
	elseif unitTypes[unitDefID] then
		UpdateTeamSlots(teamID, unitID, unitDefID, true)
		if unitTypes[unitDefID]:find("mech") then
			InsertUnitCmdDesc(unitID, sellOrderCmdDesc)
		end
	elseif GG.outpostDefs[unitDefID] then -- an upgrade
		InsertUnitCmdDesc(unitID, sellOrderCmdDesc)
	end
end


local WALL_ID = UnitDefNames["wall"].id
local GATE_ID = UnitDefNames["wall_gate"].id
local MELTDOWN = WeaponDefNames["meltdown"].id

function gadget:UnitDamaged(unitID, unitDefID, teamID, damage, paralyzer, weaponID,  projectileID, attackerID, attackerDefID, attackerTeam)
	if attackerID and attackerTeam and not AreTeamsAllied(teamID, attackerTeam) and unitDefID ~= WALL_ID and unitDefID ~= GATE_ID then
		local attackerDefType = attackerDefID and UnitDefs[attackerDefID].customParams.baseclass or ""
		if attackerDefType == "mech" then -- only mechs generate income
			-- don't allow income from nukes
			if not (weaponID and weaponID == MELTDOWN) then		
				AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if dropZones[unitID] then -- dropZone switched
		-- clear the order
		if dropShipStatus[teamID] == 2 then
			orderStatus[teamID] = 0
		end
		AddTeamResource(teamID, "metal", orderCosts[unitID])
		orderCosts[unitID] = 0
		dropZones[unitID] = nil
		teamDropZones[teamID] = nil
	elseif unitDefID == C3_ID then
		LanceControl(teamID, unitID, false)
	end
	if attackerID and not AreTeamsAllied(teamID, attackerTeam) and unitDefID ~= WALL_ID and unitDefID ~= GATE_ID then
		--AddTeamResource(attackerTeam, "metal", UnitDefs[unitDefID].metalCost * KILL_REWARD_MULT)
		AddTeamResource(teamID, "metal", UnitDefs[unitDefID].metalCost * INSURANCE_MULT)
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

local function GetWeight(mass)
	local light = mass < 40 * 100
	local medium = not light and mass < 60 * 100
	local heavy = not light and not medium and mass < 80 * 100
	local assault = not light and not medium and not heavy
	local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
	return weight
end
GG.GetWeight = GetWeight

function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp.baseclass == "mech" then
			-- sort into light, medium, heavy, assault
			local mass = unitDef.mass
			local weight = GetWeight(mass)
			unitTypes[unitDefID] = weight .. "mech"
			unitSlotChanges[unitDefID] = 1
		--[[elseif basicType == "vehicle" then
			-- sort into vehicle, vtol, aero
			local vtol = unitDef.hoverAttack
			local aero = unitDef.canFly and not vtol
			unitTypes[unitDefID] = vtol and "vtol" or aero and "aero" or "vehicle"
			unitSlotChanges[unitDefID] = (unitDef.canFly and 1) or 0.5]]
		elseif cp.dropship then
			dropShipTypes[unitDefID] = cp.dropship
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
			if unitID and ((not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID)) then -- check valid first (lazy evaluation means non-valid unitID is then not passed)
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
	for _, teamID in pairs(Spring.GetTeamList()) do
		teamSlots[teamID] = {}
		teamC3Counts[teamID] = 0
		local side = GG.teamSide and GG.teamSide[teamID] or select(5, Spring.GetTeamInfo(teamID))
		if side ~= "" then -- shouldn't be the case but maybe during loading
			teamDropShipTypes[teamID] = {def = UnitDefNames[side .. "_dropship_" .. GG.dropShipProgression[1]].id, tier = 1}
		end
		for i = 1, 3 do
			teamSlots[teamID][i] = {}
			teamSlots[teamID][i].active = i == 1
			teamSlots[teamID][i].used = 0
			teamSlots[teamID][i].available = 4
			teamSlots[teamID][i].units = {}
		end
	end
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

function ToggleSelectionByTeam(eventID, unitID, teamID, selectable)
	if teamID == MY_TEAM_ID and not (GG.AI_TEAMS and GG.AI_TEAMS[teamID]) then
		Spring.SetUnitNoSelect(unitID, not selectable)
	end
end

function AddUnitToLance(eventID, teamID, unitID, group)
	if teamID == MY_TEAM_ID then
		CallAsTeam(teamID, Spring.SetUnitGroup, unitID, group)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("LANCE", AddUnitToLance)
	gadgetHandler:AddSyncAction("TOGGLE_SELECT", ToggleSelectionByTeam)
end

end
