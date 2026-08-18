function gadget:GetInfo()
	return {
		name		= "Outpost - DropZone",
		desc		= "Controls DropZone mech purchasing abilities",
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
local tonnageMult = tonumber(modOptions and modOptions.tonnagemult or "2")

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam
--SyncedRead
local AreTeamsAllied		= Spring.AreTeamsAllied
local GetGameFrame			= Spring.GetGameFrame
local GetTeamResources		= Spring.GetTeamResources
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs
local GetUnitPosition		= Spring.GetUnitPosition
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local EMPTY_TABLE = {} -- keep as empty
local COLOURS = GG.GameConstants.colours
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local DROPZONE_IDS = {}
GG.DROPZONE_IDS = DROPZONE_IDS

-- Commands
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")
local sendOrderCmdDesc = {
	id = CMD_SEND_ORDER,
	type   = CMDTYPE.ICON,
	name   = GG.Pad("Submit", "Order"),
	action = 'submit_order',
	tooltip = "Submit your purchasing order",
	texture = "bitmaps/ui/submit.png",
}
local CMD_RUNNING_TOTAL = GG.CustomCommands.GetCmdID("CMD_RUNNING_TOTAL")
local runningTotalCmdDesc = {
	id = CMD_RUNNING_TOTAL,
	type   = CMDTYPE.ICON,
	name   = COLOURS.cbills .. GG.Pad(13, "C-Bills"," 0 "),
	--disabled = true,
	action = "menuprevious",
	texture = "bitmaps/ui/blank.png",
}
local CMD_RUNNING_TONS = GG.CustomCommands.GetCmdID("CMD_RUNNING_TONS")
local runningTonsCmdDesc = {
	id = CMD_RUNNING_TONS,
	type   = CMDTYPE.ICON,
	name   = COLOURS.tonnage .. GG.Pad(11, "Tonnes", " 0 "),
	--disabled = true,
	action = "menunext",
	texture = "bitmaps/ui/blank.png",
}
local dropZoneCmdDesc = {
	id     = GG.CustomCommands.GetCmdID("CMD_DROPZONE", 0), -- dropzone is free
	type   = CMDTYPE.ICON,
	name   = "Dropzone",
	action = 'dropzone',
	tooltip = "Set as primary dropzone",
}

local ignoredCmdDescs = {[CMD_SEND_ORDER] = true, [CMD_RUNNING_TOTAL] = true, [CMD_RUNNING_TONS] = true}
GG.ignoredCmdDescs = ignoredCmdDescs

-- Variables
local typeStrings = {"fast", "cqb", "flexible", "ranged"}
local typeStringIndex = {}
for i, v in ipairs(typeStrings) do
	typeStringIndex[v] = i
end

local typeStringAliases = { -- whitespace is to try and equalise resulting font size
	["fast"] 		= GG.Pad(10,"Recon", "EWAR"),-- "&", "Skirmisher"), 
	["cqb"] 		= GG.Pad(10,"Close", "Range"),--, "&", "Juggernaut"), 
	["flexible"] 	= GG.Pad(12,"Multi", "Role"),-- "&", "Multirole"),
	["ranged"] 		= GG.Pad(10,"Long","Range"), --"Sniper", "&", "Missile", "Boat "),
}

local mechMenuCmdDescs = {}
local menuCmdIDs = {}
for i, typeString in ipairs(typeStrings) do
	local cmdID = GG.CustomCommands.GetCmdID("CMD_MENU_" .. typeString:upper())
	mechMenuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = typeStringAliases[typeString],
		action = 'menu' .. typeString,
		tooltip = "Switch menu to " .. typeStringAliases[typeString]:gsub("%s+\n", " "),
		texture = 'bitmaps/ui/filter.png',
	}
	menuCmdIDs[cmdID] = typeString
end
menuCmdIDs[CMD_RUNNING_TOTAL] = "previous"
menuCmdIDs[CMD_RUNNING_TONS] = "next"
menuCmdIDs.n = #typeStrings

local mechCache = {} -- mechCache[unitDefID] = "fast"/"cqb"/"flexible"/"ranged" from typeStrings
GG.mechCache = mechCache 

-- Menu
local currMenu = {} -- [dropzoneID] = unitType
local currMenuIndex = {}
local locked = {} -- teamID[unitDefID] = true
-- Orders
local orderCosts = {} -- orderCosts[unitID] = cost
local orderTons = {} -- orderTons[unitID] = totalTonnage
local orderSizes = {} -- orderSizes[unitID] = size
local orderStatus = {} -- orderStatus[unitID] = number, where 0 = Ready for a new order, 1 = order submitted, 2 = dropship in play?
GG.orderStatus = orderStatus
-- Dropzones
local dropZones = {} -- dropZones[unitID] = teamID
local teamDropZones = {} -- teamDropZone[teamID] = unitID
GG.teamDropZones = teamDropZones
local dropZoneBeaconIDs = {} -- dropZoneBeaconIDs[teamID] = beaconID
GG.dropZoneBeaconIDs = dropZoneBeaconIDs
local dropZoneStatus = {} -- dropZoneStatus[teamID] = number, where 0 = Ready, 1 = Active, 2 = Cooldown
local dropZoneCoolDowns = {} -- dropZoneCoolDowns[teamID] = enableFrame
GG.dropZoneCoolDowns = dropZoneCoolDowns
-- Upgrading dropzone
local teamDropZoneLevels = {} -- teamDropZoneLevels[teamID] = {tier = 1 or 2 or 3, def = unitDefID}
local dropZoneLevels = {"leopard", "union", "overlord"}

local function GetWeight(mass) -- still used by spamBot for 'DireBolical' difficulty
	local light = mass < 40 * 100
	local medium = not light and mass < 60 * 100
	local heavy = not light and not medium and mass < 80 * 100
	local assault = not light and not medium and not heavy
	local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
	return weight
end
GG.GetWeight = GetWeight

local function AddBuildMenu(unitID, menuCmdDescs)
	InsertUnitCmdDesc(unitID, sendOrderCmdDesc)
	InsertUnitCmdDesc(unitID, runningTotalCmdDesc)
	InsertUnitCmdDesc(unitID, runningTonsCmdDesc)
	for i, cmdDesc in ipairs(menuCmdDescs) do
		InsertUnitCmdDesc(unitID, cmdDesc)
	end
end
GG.AddBuildMenu = AddBuildMenu

local function ClearCmdDescs(unitID)
	local toDelete = {}
	for i, cmdDesc in pairs(Spring.GetUnitCmdDescs(unitID)) do
		if not (cmdDesc.id < 0 or menuCmdIDs[cmdDesc.id]) then -- not a build option or menu
			toDelete[cmdDesc.id] = true
		end
	end
	for cmdID in pairs(toDelete) do -- have to use cmdIDs as each time we Remove, positions shuffle
		local i = FindUnitCmdDesc(unitID, cmdID)
		local cmdDesc = Spring.GetUnitCmdDescs(unitID)[i]
		--Spring.Echo("ClearCmdDescs: RemoveUnitCmdDesc", i, cmdDesc.id, cmdDesc.name)
		RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID))
	end
end
GG.ClearCmdDescs = ClearCmdDescs

local function ShowBuildOptionsByType(unitID, menuType, menuCache, menuIDs, typeStringIndex, lockedDescs, teamID)
	teamID = teamID or unitID -- fallback to unitID for TurretControl and AirCon
	currMenu[unitID] = menuType ~= "purchase" and menuType or currMenu[unitID]
	currMenuIndex[unitID] = menuType ~= "purchase" and typeStringIndex[menuType] or currMenuIndex[unitID]
	local cmdID = menuType and GG.CustomCommands.GetCmdID("CMD_MENU_" .. menuType:upper())
	for i, cmdDesc in pairs(GetUnitCmdDescs(unitID)) do
		if cmdDesc.id == cmdID then
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/selected.png', hidden = false})
		elseif cmdDesc.id < 0 or lockedDescs[cmdDesc.id] then --  buildoption
			if menuType == "purchase" then
				EditUnitCmdDesc(unitID, i, {hidden = type(tonumber(cmdDesc.params[1])) ~= "number"})	
			else
				-- Order matters here... nil or false = false, false or nil = nil, thanks lua
				local hide = lockedDescs[math.abs(cmdDesc.id)] or menuCache[-cmdDesc.id] ~= menuType
				EditUnitCmdDesc(unitID, i, {hidden = hide})
			end
		elseif menuCache[cmdDesc.id] then -- a button other than a buildoption which belongs to a particular menu
			EditUnitCmdDesc(unitID, i, {hidden = menuCache[cmdDesc.id] ~= menuType})
		elseif menuIDs[cmdDesc.id] then -- an actual menu button
			EditUnitCmdDesc(unitID, i, {hidden = menuType == "purchase"})
			if not (menuIDs[cmdDesc.id] == "next" or menuIDs[cmdDesc.id] == "previous") then
				EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/filter.png',})
			end
		end
	end
end
GG.ShowBuildOptionsByType = ShowBuildOptionsByType

local function ResetBuildQueue(unitID)
	local orderQueue = Spring.GetFactoryCommands(unitID, -1)
	for i, order in ipairs(orderQueue) do
		GG.Delay.DelayCall(Spring.GiveOrderToUnit,{unitID, CMD.REMOVE, {order.tag}, {"ctrl"}},1)
	end
end

local function 	LockHeavy(dropZoneID, lock) 
	local cmdDescs = GetUnitCmdDescs(dropZoneID)
	local teamID = Spring.GetUnitTeam(dropZoneID)
	for i = 1, #cmdDescs do
		local defID = cmdDescs[i].id
		if defID < 0 then
			local class = GetWeight(UnitDefs[-defID].mass)
			if class == "heavy" or class == "assault" then
				--Spring.Echo("Hiding", UnitDefs[-defID].name, class)
				locked[teamID][-defID] = lock -- TODO: pass teamID
				EditUnitCmdDesc(dropZoneID, i, {hidden = lock})		
			end
		end
	end
	-- show only the currently selected menu
	ShowBuildOptionsByType(dropZoneID, currMenu[dropZoneID], mechCache, menuCmdIDs, typeStringIndex, locked[teamID], Spring.GetUnitTeam(dropZoneID))
end
GG.LockHeavy = LockHeavy

local function DropZoneUpgrade(teamID)
	local side = GG.teamSide[teamID]
	local oldDefID = teamDropZoneLevels[teamID].def
	local newTier = teamDropZoneLevels[teamID].tier + 1
	if newTier <= #(dropZoneLevels) then -- another tier is available beyond what we currently have
		local newDefID = UnitDefNames[side .. "_dropship_" .. dropZoneLevels[newTier]].id
		teamDropZoneLevels[teamID] = {def = newDefID, tier = newTier}
		local maxTonnage = math.floor(UnitDefs[newDefID].customParams.maxtonnage * tonnageMult)
		local _, currMaxTonnage = Spring.GetTeamResources(teamID, "energy")
		local tonnageIncrease = maxTonnage - currMaxTonnage --math.floor(UnitDefs[oldDefID].customParams.maxtonnage * tonnageMult)
		Spring.SetTeamResource(teamID, "es", maxTonnage)
		Spring.AddTeamResource(teamID, "e", tonnageIncrease)
		-- first upgrade unlocks heavy and assault mechs
		GG.LockHeavy(teamDropZones[teamID], false)
	else -- max upgrade reached, disable button
		Spring.SendMessageToTeam(teamID, "Dropship Fully Upgraded!")
	end
end
GG.DropZoneUpgrade = DropZoneUpgrade


local L = {COLOURS.white .. "L"}
local C = {COLOURS.cbills .. "C"}
local T = {COLOURS.tonnage .. "T"}

local function CheckBuildOptions(unitID, teamID, slotsLeft, cmdID, slotCosts)
	local money = GetTeamResources(teamID, "metal")
	local weightLeft = GetTeamResources(teamID, "energy")
	
	for i, cmdDesc in pairs(GetUnitCmdDescs(unitID)) do
		local cmdDescID = cmdDesc.id -- localise
		if cmdDescID < 0 and cmdDescID ~= cmdID then
			local currParam = cmdDesc.params[1]
			local cCost = UnitDefs[-cmdDescID].metalCost * (cmdDesc.action == "resurrectmech" and GG.RECOVER_DISCOUNT or 1) -- Oh dear me
			local tCost = UnitDefs[-cmdDescID].energyCost
			local limitLeft = slotsLeft - (orderSizes[unitID] or (slotCosts and slotCosts[-cmdDescID]) or 0)
			if type(tonumber(currParam)) == "number" then
				-- units are queued, don't do anything
			elseif limitLeft < 1 then
				EditUnitCmdDesc(unitID, i, {disabled = true, params = L})
			elseif tCost > weightLeft then
				EditUnitCmdDesc(unitID, i, {disabled = true, params = T})
			elseif cCost > money then
				EditUnitCmdDesc(unitID, i, {disabled = true, params = C})
			elseif cmdDesc.disabled then
				EditUnitCmdDesc(unitID, i, {disabled = false, params = EMPTY_TABLE})
			end
		end
	end
end
GG.CheckBuildOptions = CheckBuildOptions

function UpdateButtons(unitID, teamID, arrived) -- Toggles Submit Order vs Order Sent
	if arrived then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = true, name = GG.Pad("Dropship", "Arrived")})
	elseif orderStatus[unitID] == 0 then -- ready for new order
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = false, name = GG.Pad("Submit","Order"), texture = "bitmaps/ui/submit.png"})
		if orderSizes[unitID] == 0 then
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = COLOURS.cbills .. GG.Pad(13, "C-Bills", " 0 ")})
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = COLOURS.tonnage .. GG.Pad(11, "Tonnes", " 0 ")})
		end
	elseif orderStatus[unitID] >= 1 then -- order submitted
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {name = GG.Pad("Order","Sent"), texture = "bitmaps/ui/submit2.png"})
	end
end

function OrderFinished(unitID, teamID)
	ResetBuildQueue(unitID)
	orderCosts[unitID] = 0
	orderTons[unitID] = 0
	orderSizes[unitID] = 0
	if dropZones[unitID] then
		ShowBuildOptionsByType(unitID, currMenu[unitID], mechCache, menuCmdIDs, typeStringIndex, locked[teamID], teamID)
	end
end
GG.OrderFinished = OrderFinished -- for outpost_airCon build menu

local function DropShipAvailable(teamID)
	if orderStatus[unitID] == 0 then -- only play this sound if no new order is queued
		GG.PlaySoundForTeam(teamID, "bb_reinforcements_available", 1)
	end
end

local function CleanupOrder(unitID, teamID)
	orderStatus[unitID] = 0 -- ready for new order
	UpdateButtons(unitID, teamID)
end
GG.CleanupOrder = CleanupOrder -- for outpost_airCon build menu

function DropZoneCoolDown(teamID) -- called when Dropship leaves (via UnitDestroyed), to enable "Submit Order"
	local dead = select(3, Spring.GetTeamInfo(teamID))
	if dead then return end
	if not dead and teamID and teamDropZoneLevels[teamID] then
		local unitID = teamDropZones[teamID]
		local beaconID = GG.dropZoneBeaconIDs[teamID]	
		if unitID then -- dropzone might have died in the meantime
			OrderFinished(unitID, teamID)
			CleanupOrder(unitID, teamID)
		end
		-- Dropship is no longer ACTIVE, it is entering COOLDOWN
		--GG.PlaySoundForTeam(teamID, "bb_reinforcements_inbound_eta_30", 1)
		dropZoneStatus[teamID] = 2
		SetTeamRulesParam(teamID, "STATUS", 2)
		local dropShipDef = UnitDefs[teamDropZoneLevels[teamID].def]
		local enableFrame = GetGameFrame() + dropShipDef.customParams.cooldown
		dropZoneCoolDowns[teamID] = enableFrame
		Spring.SetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN", enableFrame) -- frame this team can call dropship again
		GG.Delay.DelayCall(DropShipAvailable, {teamID}, tonumber(dropShipDef.customParams.cooldown))
	else
		-- Somehow this can happen, but it doesn't cause any problems
		--Spring.Echo("FLOZi logic fail, a non-dead team seems to be missing teamDropZoneLevels?")
	end
end

local function Refund(teamID, cost, weight)
	--Spring.Echo("Refund", teamID, cost, weight)
	if cost and weight then
		Spring.SendMessageToTeam(teamID, "Refunding order, there is no dropzone")
		GG.PlaySoundForTeam(teamID, "bb_reinforcements_refund", 1)
		AddTeamResource(teamID, "metal", cost)
		AddTeamResource(teamID, "energy", weight)
	end
end

-- Factories can't implement gadget:CommandFallback, so fake it ourselves
local function SendCommandFallback(cost, weight, unitID, unitDefID, teamID)
	--Spring.Echo("SendCommandFallback", unitID, unitDefID, teamID, cost, weight, Spring.GetGameFrame())
	if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) or not teamDropZones[teamID] or orderStatus[unitID] == 0 then 
		-- dropZone died, yes future self, this is still reachable
		return false
	end 
	if dropZoneStatus[teamID] == 0 then -- Dropship is READY
		local unitID = teamDropZones[teamID]
		-- CALL DROPSHIP
		local orderQueue = Spring.GetFullBuildQueue(unitID)
		if not orderQueue then 
			return 
		end -- dropzone died TODO: Transfer to new DZ if there is one
		if #orderQueue > 0 then -- proceed with order
			local beaconID = GG.dropZoneBeaconIDs[teamID]
						--beaconID, beaconPointID, teamID, dropshipType, 					cargo, cost, sound, delay
			GG.DropshipDelivery(beaconID, beaconID, teamID, teamDropZoneLevels[teamID].def, orderQueue, 0, nil, 0)
			Spring.SendMessageToTeam(teamID, "Sending purchase order for the following:")
			for i, order in ipairs(orderQueue) do
				for orderDefID, count in pairs(order) do
					Spring.SendMessageToTeam(teamID, UnitDefs[orderDefID].humanName .. ":\t" .. count)
				end
			end
			-- Dropship can now be considered ACTIVE even though it hasn't arrived yet
			dropZoneStatus[teamID] = 1
			SetTeamRulesParam(teamID, "STATUS", 1)
		else -- cancelled
			Spring.SendMessageToTeam(teamID, "Order cancelled, queue is empty")
			dropZoneStatus[teamID] = 0
			SetTeamRulesParam(teamID, "STATUS", 0)
			orderStatus[unitID] = 0
			UpdateButtons(unitID, teamID)
		end
		-- clean up (regardless of whether or not order was fulfilled or cancelled)
		ResetBuildQueue(unitID)
		--OrderFinished(unitID, teamID)
	else -- Dropship is ACTIVE or COOLDOWN
		GG.Delay.DelayCall(SendCommandFallback, {cost, weight, unitID, unitDefID, teamID}, 16)
	end
end

local firstDZCache = {}

local function SetDropZone(beaconID, teamID)
	local currDropZone = teamDropZones[teamID]
	if currDropZone then
		DestroyUnit(currDropZone, false, true)
		DropZoneCoolDown(teamID, true) -- reset the timer
	else
		locked[teamID] = {}
	end
	local x,y,z = GetUnitPosition(beaconID)
	local side = GG.teamSide[teamID]
	if not side then return end -- a weird bug to avoid here, maybe due to dead team?
	local dropZoneID = CreateUnit(side .. "_dropzone", x,y,z, "s", teamID)
	ShowBuildOptionsByType(dropZoneID, "fast", mechCache, menuCmdIDs, typeStringIndex, locked[teamID], teamID)
	dropZones[dropZoneID] = teamID
	teamDropZones[teamID] = dropZoneID
	dropZoneBeaconIDs[teamID] = beaconID
	Spring.SetUnitRulesParam(beaconID, "secure", 1)
	Spring.SetUnitNoSelect(beaconID, true)
	if firstDZCache[teamID] then 
		GG.PlaySoundForTeam(teamID, "bb_dropzone_reassigned", 1)
	else -- don't play sound on the first one
		firstDZCache[teamID] = true
		Spring.SendCommands("viewspring")
		GG.PlaySoundForTeam(teamID, "bb_startup_command_authority", 1)
	end
end

local function PurchaseOrders(unitID, unitDefID, teamID, cmdID, cmdOptions, completionFunc, menuCache, menuIDs, typeStrings, typeStringIndex, slotsLeft, lockedDescs)
	local typeString = menuIDs[cmdID]
	local rightClick = cmdOptions.right
	if typeString then
		currMenuIndex[unitID] = currMenuIndex[unitID] or 1
		if typeString == "next" then
			local newIndex = currMenuIndex[unitID]+1
			if newIndex > menuIDs.n then newIndex = 1 end
			typeString = typeStrings[newIndex]
		elseif	typeString == "previous" then
			local newIndex = currMenuIndex[unitID]-1
			if newIndex < 1 then newIndex = menuIDs.n end
			typeString = typeStrings[newIndex]
		end
		ShowBuildOptionsByType(unitID, typeString, menuCache, menuIDs, typeStringIndex, lockedDescs, dropZones[unitID])
		GG.PlaySoundForTeam(teamID, "IncomingChat", 1)
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
			if (slotsLeft - runningSize) < 1 then  -- not enough C3 bandwidth
				GG.PlaySoundForTeam(teamID, "bb_insufficient_c3bandwidth", 1)
				return false 
			end
			local newTotal = runningTotal + cost
			local newTons = runningTons + weight
			if  cost <= money and weight <= tonnage then -- check we can afford it
				--Spring.SendMessageToTeam(teamID, "Running C-Bills: " .. newTotal)
				--Spring.SendMessageToTeam(teamID, "Running Tonnage: " .. newTons)
				orderCosts[unitID] = newTotal
				orderTons[unitID] = newTons
				orderSizes[unitID] = runningSize + 1
				-- Take the costs upfront, can be reimbursed
				UseTeamResource(teamID, "metal", cost)
				UseTeamResource(teamID, "energy", weight)
				CheckBuildOptions(unitID, teamID, slotsLeft, cmdID)
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = COLOURS.cbills .. GG.Pad(13, "C-Bills", "" .. newTotal)})
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = COLOURS.tonnage .. GG.Pad(11, "Tonnes", "" .. newTons)})
				return true
			else
				if cost > money then  -- not enough money
					GG.PlaySoundForTeam(teamID, "bb_insufficient_cbills", 1)
				elseif weight > tonnage then  -- not enough tonnage
					GG.PlaySoundForTeam(teamID, "bb_insufficient_tonnage", 1)
				end
				return false
			end
		elseif runningSize > 0 then  -- only allow removal if order contains units (prevent -ve running totals!)
			local cmdDesc = GetUnitCmdDescs(unitID, FindUnitCmdDesc(unitID, cmdID))[1] -- TODO: This is just awful
			local currNumber = tonumber(cmdDesc.params[1]) or 0
			if currNumber > 0 then -- only allow if more than 1 of **this** unit currently on order
				orderCosts[unitID] = runningTotal - cost
				orderTons[unitID] = runningTons - weight
				-- reimburse the costs
				AddTeamResource(teamID, "metal", cost)
				AddTeamResource(teamID, "energy", weight)
				orderSizes[unitID] = runningSize - 1
				CheckBuildOptions(unitID, teamID, slotsLeft)
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = COLOURS.cbills .. GG.Pad(13, "C-Bills", "" .. (runningTotal - cost))})
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = COLOURS.tonnage .. GG.Pad(11, "Tonnes", "" .. (runningTons - weight))})
				return true
			else
				return false
			end
		end	
	elseif cmdID == CMD_SEND_ORDER then
		if rightClick then
			if orderStatus[unitID] > 0 then
				-- cancelling the order, update the buttons
				orderStatus[unitID] = 0
				UpdateButtons(unitID, teamID)
				return true
			else return false end
		elseif orderStatus[unitID] >= 1 then
			Spring.SendMessageToTeam(teamID, "Cannot submit order, there is already an order pending!", orderStatus[unitID])
			return false -- we already have submitted an order and not cancelled it
		end
		if (orderSizes[unitID] or 0) == 0 then  -- don't allow empty orders
			Spring.SendMessageToTeam(teamID, "Cannot submit order, queue is empty!")
			return false 
		end
		orderStatus[unitID] = Spring.GetGameFrame() --1
		UpdateButtons(unitID, teamID)
		ShowBuildOptionsByType(unitID, dropZones[unitID] and "purchase" or "deploy", menuCache, menuIDs, typeStringIndex, lockedDescs, teamID)
		if dropZoneStatus[teamID] ~= 0 then -- check here so it only plays once rather than every fallback
			GG.PlaySoundForTeam(teamID, "bb_reinforcements_queued", 1)
		end
		GG.Delay.DelayCall(completionFunc, {orderCosts[unitID], orderTons[unitID], unitID, unitDefID, teamID}, 16)
		return true
	end
	return true
end
GG.PurchaseOrders = PurchaseOrders

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	-- DROPZONE PURCHASE ORDERS
	if dropZones[unitID] then
		return dropZoneStatus[teamID] ~= 1 and PurchaseOrders(unitID, unitDefID, teamID, cmdID, cmdOptions, SendCommandFallback, mechCache, menuCmdIDs, typeStrings, typeStringIndex, GG.TeamSlotsRemaining(teamID), locked[teamID])
	-- DROPZONE PLACEMENT ORDERS
	elseif unitDefID == BEACON_ID then
		if cmdID == dropZoneCmdDesc.id then
			if Spring.GetUnitRulesParam(unitID, "secure") == 0 then 
				Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Under attack!")
				GG.PlaySoundForTeam(teamID, "bb_dropzone_reassign_blocked_enemy", 1)
				return false 
			elseif dropZoneStatus[teamID] == 1 then
				-- double check if dropship is not in action
				if Spring.GetTeamUnitDefCount(teamID, teamDropZoneLevels[teamID].def) ~= 0 then 
					Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Dropship is active!")
					GG.PlaySoundForTeam(teamID, "bb_dropzone_reassign_blocked", 1)
					return false
				end
				-- TODO: this will allow the command otherwise which is also dangerous, as dropship can be 'ACTIVE' without being in play
				-- TODO: Solution is probably to make a new dropship state and have ACTIVE only the case when it is on map
			elseif GG.teamDropZones[teamID] and GG.orderStatus[GG.teamDropZones[teamID]] > 0 then
				Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Order pending!")
				GG.PlaySoundForTeam(teamID, "bb_dropzone_reassign_blocked", 1)
				return false 
			end
			SetDropZone(unitID, teamID)
		end
	end
	return true
end

function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
	if dropZones[unitID] then
		return false
	end
	return true
end

function gadget:AllowUnitBuildStep(builderID, builderTeam, unitID, unitDefID, part)
	local builderDefID = Spring.GetUnitDefID(builderID)
	local builderDef = UnitDefs[builderDefID]
	if builderDef.name:find("dropzone") then
		return false
	end
	return true -- turret control
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local unitDef = UnitDefs[unitDefID]
	if unitDefID == BEACON_ID then
		InsertUnitCmdDesc(unitID, dropZoneCmdDesc)
	elseif DROPZONE_IDS[unitDefID] then
		ClearCmdDescs(unitID, true)
		--ClearCmdDescs(unitID, true)
		AddBuildMenu(unitID, mechMenuCmdDescs)
		dropZones[unitID] = teamID
		teamDropZones[teamID] = unitID
		SetTeamRulesParam(teamID, "STATUS", 0)
		if not teamDropZoneLevels[teamID] then
			local side = GG.teamSide and GG.teamSide[teamID] or select(5, Spring.GetTeamInfo(teamID))
			teamDropZoneLevels[teamID] = {def = UnitDefNames[side .. "_dropship_" .. dropZoneLevels[1]].id, tier = 1}
		end
		if teamDropZoneLevels[teamID].tier == 1 then
			LockHeavy(unitID, true)
		end
		orderStatus[unitID] = 0
	elseif GG.dropShipCache[unitDefID] == "mech" then
		UpdateButtons(teamDropZones[teamID], teamID, true)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if dropZones[unitID] then -- dropZone switched
		--Spring.Echo("UnitDestroyed dropZone uID", unitID, "tID", teamID) 
		--Spring.Echo("orderStatus", orderStatus[unitID], "orderCosts", orderCosts[unitID], "orderTons", orderTons[unitID], "orderSizes",orderSizes[unitID])
		-- Refund & clear order
		Refund(teamID, orderCosts[unitID], orderTons[unitID])
		OrderFinished(unitID, teamID)
		-- clearup the dropzone
		orderStatus[unitID] = 0
		teamDropZones[teamID] = nil
		dropZones[unitID] = nil
		Spring.SetUnitNoSelect(dropZoneBeaconIDs[teamID], false)
		dropZoneBeaconIDs[teamID] = nil
	elseif GG.dropShipCache[unitDefID] == "mech" then-- main dropship
		DropZoneCoolDown(teamID)
	elseif mechCache[unitDefID] then
		-- reimburse 'weight'
		AddTeamResource(teamID, "energy", UnitDefs[unitDefID].energyCost)
	end
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if dropZoneBeaconIDs[oldTeam] == unitID then
		local dropZoneID = teamDropZones[oldTeam]
		DelayCall(DestroyUnit, {dropZoneID, false, true}, 1)
	else
		gadget:UnitDestroyed(unitID, unitDefID, oldTeam)
		if newTeam ~= GAIA_TEAM_ID then
			gadget:UnitCreated(unitID, unitDefID, newTeam)
		end
	end
end


function gadget:GamePreload()
	for unitDefID, unitDef in pairs(UnitDefs) do
		local name = unitDef.name
		local cp = unitDef.customParams
		if cp.baseclass == "mech" then
			-- sort into light, medium, heavy, assault
			mechCache[unitDefID] = cp.menu
		elseif name:find("dropzone") then -- check for dropzones first
			DROPZONE_IDS[unitDefID] = true
		end
	end
	for _, teamID in pairs(Spring.GetTeamList()) do
		dropZoneStatus[teamID] = 0
		--orderStatus[unitID] = 0
	end
	GG.DROPZONE_IDS = DROPZONE_IDS
end


function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		-- check if orders are still too expensive
		for unitID, teamID in pairs(dropZones) do
			CheckBuildOptions(unitID, teamID, GG.TeamSlotsRemaining(teamID, unitType))
		end
		-- reduce cooldown timers
		for teamID, enableFrame in pairs(dropZoneCoolDowns) do
			local framesRemaining = enableFrame - n
			local unitID = teamDropZones[teamID]
			if unitID and ((not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID)) then -- check valid first (lazy evaluation means non-valid unitID is then not passed)
				dropZoneCoolDowns[teamID] = -1
			else
				if framesRemaining <= 0 and dropZoneStatus[teamID] == 2 then
					dropZoneCoolDowns[teamID] = -2
					-- dropship is now READY
					dropZoneStatus[teamID] = 0
					SetTeamRulesParam(teamID, "STATUS", 0)
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
		if DROPZONE_IDS[unitDefID] then
			Spring.DestroyUnit(unitID, false, true)
		else
			gadget:UnitCreated(unitID, unitDefID, teamID)
		end
	end
end

else
--	UNSYNCED
return false end