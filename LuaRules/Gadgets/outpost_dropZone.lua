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
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local EMPTY_TABLE = {} -- keep as empty
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local BEACON_ID = UnitDefNames["beacon"].id
local DROPZONE_IDS = {}
GG.DROPZONE_IDS = DROPZONE_IDS

-- Commands
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
	name   = "Order\nC-Bills: \n0",
	disabled = true,
}
local CMD_RUNNING_TONS = GG.CustomCommands.GetCmdID("CMD_RUNNING_TONS")
local runningTonsCmdDesc = {
	id = CMD_RUNNING_TONS,
	type   = CMDTYPE.ICON,
	name   = "Order\nTonnes: \n0",
	disabled = true,
}
local dropZoneCmdDesc = {
	id     = GG.CustomCommands.GetCmdID("CMD_DROPZONE", 0), -- dropzone is free
	type   = CMDTYPE.ICON,
	name   = "Dropzone",
	action = 'dropzone',
	tooltip = "Set as primary dropzone",
}

local ignoredCmdDescs = {[CMD_SEND_ORDER] = true, [CMD_RUNNING_TOTAL] = true, [CMD_RUNNING_TONS] = true}

-- Variables
local typeStrings = {"fast", "cqb", "flexible", "ranged"}
local typeStringAliases = { -- whitespace is to try and equalise resulting font size
	["fast"] 		= GG.Pad(10,"Scout"),-- "&", "Skirmisher"), 
	["cqb"] 		= GG.Pad(10,"Striker"),--, "&", "Juggernaut"), 
	["flexible"] 	= GG.Pad(10,"Brawler"),-- "&", "Multirole"),
	["ranged"] 		= GG.Pad(10,"Ranged"), --"Sniper", "&", "Missile", "Boat "),
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
		tooltip = "Switch menu to " .. typeStringAliases[typeString]:gsub("%s+\n", " "),
		texture = 'bitmaps/ui/filter.png',
	}
	menuCmdIDs[cmdID] = typeString
	ignoredCmdDescs[cmdID] = 1
end

local mechCache = {} -- mechCache[unitDefID] = "fast"/"cqb"/"flexible"/"ranged" from typeStrings
GG.mechCache = mechCache 

-- Menu
local currMenu = {} -- [dropzoneID] = unitType
local locked = {} -- unitDefID = true
-- Orders
local orderCosts = {} -- orderCosts[unitID] = cost
local orderTons = {} -- orderTons[unitID] = totalTonnage
local orderSizes = {} -- orderSizes[unitID] = size
local orderStatus = {} -- orderStatus[teamID] = number, where 0 = Ready for a new order, 1 = order submitted, 2 = dropship in play?
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

local function GetWeight(mass) -- still used by spamBot fore 'DireBolical' difficulty
	local light = mass < 40 * 100
	local medium = not light and mass < 60 * 100
	local heavy = not light and not medium and mass < 80 * 100
	local assault = not light and not medium and not heavy
	local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
	return weight
end
GG.GetWeight = GetWeight

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
end

local function ShowBuildOptionsByType(unitID, unitType)
	currMenu[unitID] = unitType
	local cmdID = unitType and GG.CustomCommands.GetCmdID("CMD_MENU_" .. unitType:upper())
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id == cmdID then
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/selected.png',})
		elseif cmdDesc.id < 0 then
			-- Order matters here... nil or false = false, false or nil = nil, thanks lua
			local hide = locked[-cmdDesc.id] or mechCache[-cmdDesc.id] ~= unitType
			EditUnitCmdDesc(unitID, i, {hidden = hide})
		elseif ignoredCmdDescs[cmdDesc.id] == 1 then 
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/filter.png',})
		end
	end
end

local function ResetBuildQueue(unitID)
	local orderQueue = Spring.GetFactoryCommands(unitID, -1)
	for i, order in ipairs(orderQueue) do
		GG.Delay.DelayCall(Spring.GiveOrderToUnit,{unitID, CMD.REMOVE, {order.tag}, {"ctrl"}},1)
	end
end

local function 	LockHeavy(dropZone, lock) 
	local cmdDescs = GetUnitCmdDescs(dropZone)
	for i = 1, #cmdDescs do
		local defID = cmdDescs[i].id
		if defID < 0 then
			local class = GetWeight(UnitDefs[-defID].mass)
			if class == "heavy" or class == "assault" then
				--Spring.Echo("Hiding", UnitDefs[-defID].name, class)
				locked[-defID] = lock
				EditUnitCmdDesc(dropZone, i, {hidden = lock})		
			end
		end
	end
	-- show only the currently selected menu
	ShowBuildOptionsByType(dropZone, currMenu[dropZone])
end
GG.LockHeavy = LockHeavy

local function DropZoneUpgrade(teamID)
	local side = GG.teamSide[teamID]
	local oldDefID = teamDropZoneLevels[teamID].def
	local newTier = teamDropZoneLevels[teamID].tier + 1
	if newTier <= #(dropZoneLevels) then -- another tier is available beyond what we currently have
		local newDefID = UnitDefNames[side .. "_dropship_" .. dropZoneLevels[newTier]].id
		teamDropZoneLevels[teamID] = {def = newDefID, tier = newTier}
		local maxTonnage = UnitDefs[newDefID].customParams.maxtonnage
		local tonnageIncrease = maxTonnage - UnitDefs[oldDefID].customParams.maxtonnage
		Spring.SetTeamResource(teamID, "es", maxTonnage)
		Spring.AddTeamResource(teamID, "e", tonnageIncrease)
		-- first upgrade unlocks heavy and assault mechs
		GG.LockHeavy(teamDropZones[teamID], false)
	else -- max upgrade reached, disable button
		Spring.SendMessageToTeam(teamID, "Dropship Fully Upgraded!")
	end
end
GG.DropZoneUpgrade = DropZoneUpgrade

local L = {"L"}
local C = {"C"}
local T = {"T"}

local function CheckBuildOptions(unitID, teamID, cmdID)
	local money = GetTeamResources(teamID, "metal")
	local weightLeft = GetTeamResources(teamID, "energy")
	
	local cmdDescs = GetUnitCmdDescs(unitID) or EMPTY_TABLE
	for cmdDescID = 1, #cmdDescs do
		local buildDefID = cmdDescs[cmdDescID].id
		local cmdDesc = cmdDescs[cmdDescID]
		if cmdDesc.id ~= cmdID and not ignoredCmdDescs[cmdDesc.id] then
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
			and (GG.TeamSlotsRemaining(teamID) - (orderSizes[unitID] or 0))	< 1 then -- builder order but no team slots left
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = L})
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

function UpdateButtons(teamID, arrived) -- Toggles Submit Order vs Order Sent
	local unitID = teamDropZones[teamID]
	if arrived then
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = true, name = "Dropship \nArrived "})
	elseif orderStatus[teamID] == 0 then -- ready for new order
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = false, name = "Submit \nOrder "})
		if orderSizes[teamID] == 0 then
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = "Order\nC-Bills: \n0"})
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = "Order\nTonnes: \n0"})
		end
	elseif orderStatus[teamID] >= 1 then -- order submitted
		EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {name = "Order \nSent "})
	end
end

function OrderFinished(unitID, teamID)
	ResetBuildQueue(unitID)
	orderCosts[unitID] = 0
	orderTons[unitID] = 0
	orderSizes[unitID] = 0
end

function DropZoneCoolDown(teamID) -- called by Dropship once it has left, to enable "Submit Order"
	local dead = select(3, Spring.GetTeamInfo(teamID))
	if dead then return end
	if not dead and teamID and teamDropZoneLevels[teamID] then
		local unitID = teamDropZones[teamID]
		local beaconID = GG.dropZoneBeaconIDs[teamID]
		orderStatus[teamID] = 0 -- ready for new order
		if unitID then -- dropzone might have died in the meantime
			UpdateButtons(teamID)
		end
		-- Dropship is no longer ACTIVE, it is entering COOLDOWN
		GG.PlaySoundForTeam(teamID, "BB_Reinforcements_Inbound_ETA_30", 1)
		dropZoneStatus[teamID] = 2
		SetTeamRulesParam(teamID, "STATUS", 2)
		local dropShipDef = UnitDefs[teamDropZoneLevels[teamID].def]
		local enableFrame = GetGameFrame() + dropShipDef.customParams.cooldown
		dropZoneCoolDowns[teamID] = enableFrame
		Spring.SetTeamRulesParam(teamID, "DROPSHIP_COOLDOWN", enableFrame) -- frame this team can call dropship again
	else
		Spring.Echo("FLOZi logic fail, a non-dead team seems to be missing teamDropZoneLevels?")
	end
end

-- Factories can't implement gadget:CommandFallback, so fake it ourselves
local function SendCommandFallback(unitID, unitDefID, teamID, cost, weight)
	if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) then return false end -- unit died
	if orderStatus[teamID] == 0 then return end -- order was cancelled
	if dropZoneStatus[teamID] == 0 then -- Dropship is READY
		local unitID = teamDropZones[teamID]
		if not unitID then -- Dropzone has died and not been replaced whilst order is due, refund
			Spring.SendMessageToTeam(teamID, "Refunding order, there is no dropzone")
			AddTeamResource(teamID, "metal", cost)
			AddTeamResource(teamID, "energy", weight)
		else
			-- CALL DROPSHIP
			local orderQueue = Spring.GetFullBuildQueue(unitID)
			if not orderQueue then return end -- dropzone died TODO: Transfer to new DZ if there is one
			if #orderQueue > 0 then -- proceed with order
				-- TODO: Sound needs to change?
				local beaconID = GG.dropZoneBeaconIDs[teamID]
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
				orderStatus[teamID] = 0
				UpdateButtons(teamID)
			end
		end
		-- clean up (regardless of whether or not order was fulfilled or cancelled)
		OrderFinished(unitID, teamID)
	else -- Dropship is ACTIVE or COOLDOWN
		GG.Delay.DelayCall(SendCommandFallback, {unitID, unitDefID, teamID, cost, weight}, 16)
	end
end

local function SetDropZone(beaconID, teamID)
	local currDropZone = teamDropZones[teamID]
	if currDropZone then
		DestroyUnit(currDropZone, false, true)
		DropZoneCoolDown(teamID, true) -- reset the timer
	end
	local x,y,z = GetUnitPosition(beaconID)
	local side = GG.teamSide[teamID]
	if not side then return end -- a weird bug to avoid here, maybe due to dead team?
	local dropZoneID = CreateUnit(side .. "_dropzone", x,y,z, "s", teamID)
	dropZones[dropZoneID] = teamID
	teamDropZones[teamID] = dropZoneID
	dropZoneBeaconIDs[teamID] = beaconID
	Spring.SetUnitRulesParam(beaconID, "secure", 1)
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	-- DROPZONE PURCHASE ORDERS
	if dropZones[unitID] then
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
				if (GG.TeamSlotsRemaining(teamID) - runningSize) < 1 then -- TODO: Can this even happen? Maybe with giving units --[[ orderSizesPending[unitID]]
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
					CheckBuildOptions(unitID, teamID, cmdID)
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = "Order\nC-Bills: \n" .. newTotal})
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = "Order\nTonnes: \n" .. newTons})
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
					-- reimburse the costs
					AddTeamResource(teamID, "metal", cost)
					AddTeamResource(teamID, "energy", weight)
					orderSizes[unitID] = runningSize - 1
					CheckBuildOptions(unitID, teamID)
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TOTAL), {name = "Order\nC-Bills: \n" .. runningTotal - cost})
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_RUNNING_TONS), {name = "Order\nTonnes: \n" .. runningTons - weight})
					return true
				else
					return false
				end
			end	
		elseif cmdID == CMD_SEND_ORDER then
			if rightClick then
				if orderStatus[teamID] > 0 then
					-- cancelling the order, update the buttons
					orderStatus[teamID] = 0
					UpdateButtons(teamID)
					return true
				else return false end
			elseif orderStatus[teamID] >= 1 then
				Spring.SendMessageToTeam(teamID, "Cannot submit order, there is already an order pending!", orderStatus[teamID])
				return false -- we already have submitted an order and not cancelled it
			end
			if (orderSizes[unitID] or 0) == 0 then  -- don't allow empty orders
				Spring.SendMessageToTeam(teamID, "Cannot submit order, queue is empty!")
				return false 
			end
			orderStatus[teamID] = Spring.GetGameFrame() --1
			UpdateButtons(teamID)
			GG.Delay.DelayCall(SendCommandFallback, {unitID, unitDefID, teamID, cost}, 16)
			return true
		end
	-- DROPZONE PLACEMENT ORDERS
	elseif unitDefID == BEACON_ID then
		if cmdID == dropZoneCmdDesc.id then
			if Spring.GetUnitRulesParam(unitID, "secure") == 0 then 
				Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Under attack!")
				return false 
			elseif dropZoneStatus[teamID] == 1 then
				-- double check if dropship is not in action
				if Spring.GetTeamUnitDefCount(teamID, teamDropZoneLevels[teamID].def) ~= 0 then 
					Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Dropship is active!")
					return false
				end
				-- TODO: this will allow the command otherwise which is also dangerous, as dropship can be 'ACTIVE' without being in play
				-- TODO: Solution is probably to make a new dropship state and have ACTIVE only the case when it is on map
			elseif GG.orderStatus[teamID] > 0 and GG.teamDropZones[teamID] then
				Spring.SendMessageToTeam(teamID, "Cannot establish dropzone - Order pending!")
				return false 
			end
			SetDropZone(unitID, teamID)
		end
	end
	return true
end

function gadget:AllowResourceTransfer(oldTeamID, newTeamID, res, amount) -- TODO: move to purchasing
	if res == "e" then 
		return false 
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
		ClearBuildOptions(unitID, true)
		AddBuildMenu(unitID)
		dropZones[unitID] = teamID
		teamDropZones[teamID] = unitID
		SetTeamRulesParam(teamID, "STATUS", 0)
		if teamDropZoneLevels[teamID].tier == 1 then
			LockHeavy(unitID, true)
		end
	elseif GG.dropShipCache[unitDefID] == "mech" then
		UpdateButtons(teamID, true)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	if dropZones[unitID] then -- dropZone switched
		-- clear the order
		if dropZoneStatus[teamID] == 2 then -- dropship is in cooldown
			orderStatus[teamID] = 0
		end
		AddTeamResource(teamID, "metal", orderCosts[unitID] or 0)
		AddTeamResource(teamID, "energy", orderTons[unitID] or 0)
		teamDropZones[teamID] = nil
		orderCosts[unitID] = 0
		orderTons[unitID] = 0
		dropZones[unitID] = nil
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
		orderStatus[teamID] = 0
	end
	GG.DROPZONE_IDS = DROPZONE_IDS
end


function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		-- check if orders are still too expensive
		for unitID, teamID in pairs(dropZones) do
			CheckBuildOptions(unitID, teamID)
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

function gadget:GameStart()
	-- math.randomseed is only seeded at game start, so sides are determined then
	for _, teamID in pairs(Spring.GetTeamList()) do
		local side = GG.teamSide and GG.teamSide[teamID] or select(5, Spring.GetTeamInfo(teamID))
		if side ~= "" then -- shouldn't be the case but maybe during loading
			teamDropZoneLevels[teamID] = {def = UnitDefNames[side .. "_dropship_" .. dropZoneLevels[1]].id, tier = 1}
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

end
