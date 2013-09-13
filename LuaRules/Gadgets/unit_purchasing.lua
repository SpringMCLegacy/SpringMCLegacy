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
local GetGameFrame			= Spring.GetGameFrame
local GetTeamResources		= Spring.GetTeamResources
local GetUnitPosition		= Spring.GetUnitPosition
--SyncedCtrl
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
local DROPSHIP_DELAY = 30 * 30 -- 30s

-- local NUM_ICONS_PER_PAGE = 3 * 8
	
local CMD_SEND_ORDER = GG.CustomCommands.GetCmdID("CMD_SEND_ORDER")

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
local orderCosts = {} -- orderCosts[unitID] = cost
local dropZones = {} -- dropZones[unitID] = teamID
local teamDropZones = {} -- teamDropZone[teamID] = unitID

local sendOrderCmdDesc = {
	id = CMD_SEND_ORDER,
	type   = CMDTYPE.ICON,
	name   = "Submit \nOrder ",
	action = 'submit_order',
	tooltip = "Submit your purchasing order",
}

local unitTypes = {} -- unitTypes[unitDefID] = "lightmech" etc from typeStrings

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
	local cmdDescs = Spring.GetUnitCmdDescs(unitID)
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
			if cCost > money and (currParam == "" or currParam == "C") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"C"}})
			elseif tCost > weightLeft then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = {"T"}})
			else
				if cmdDesc.disabled and currParam == "C" then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = {}})
				end
			end
		end
	end
end

local DROPSHIP_COOLDOWN = 10 * 30 -- 10s
local startMin, startSec = GG.FramesToMinutesAndSeconds(DROPSHIP_COOLDOWN)
local coolDowns = {} -- coolDowns[teamID] = enableFrame

function SendButtonCoolDown(unitID, teamID)
	EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, CMD_SEND_ORDER), {disabled = true, name = startMin .. ":" .. startSec})
	coolDowns[teamID] = GetGameFrame() + DROPSHIP_COOLDOWN
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
			local cost = UnitDefs[-cmdID].metalCost
			local runningTotal = orderCosts[unitID] or 0
			local money = GetTeamResources(teamID, "metal")
			if not rightClick then
				-- TODO: limit count
				if runningTotal + cost < money then -- check we can afford it
					Spring.Echo("Running Total: " .. runningTotal + cost)
					orderCosts[unitID] = runningTotal + cost
					CheckBuildOptions(unitID, teamID, money - (runningTotal + cost), cmdID)
					return true
				else
					return false -- not enough money
				end
			else
				orderCosts[unitID] = runningTotal - cost
				CheckBuildOptions(unitID, teamID, money - (runningTotal - cost))
				return true -- always allow removal
			end
			
		elseif cmdID == CMD_SEND_ORDER then
			-- TODO: cooldown - remove all options / disable send order button?
			local orderQueue = Spring.GetFullBuildQueue(unitID)
			local money = GetTeamResources(teamID, "metal")
			local cost = orderCosts[unitID]
			-- check we can afford the order; possible that a previously affordable order is now too much e.g. if towers have been purchased
			if cost > money then return false end
			local side = UnitDefs[unitDefID].name:sub(1,2) -- send dropship of correct side
			GG.DropshipDelivery(unitID, teamID, side .. "_dropship_fx", orderQueue, cost, "BB_Reinforcements_Inbound_ETA_30", DROPSHIP_DELAY)
			Spring.Echo("Sending purchase order for the following:")
			for i, order in ipairs(orderQueue) do
				for orderDefID, count in pairs(order) do
					Spring.Echo(UnitDefs[orderDefID].name, count)
				end
			end
			ResetBuildQueue(unitID)
			orderCosts[unitID] = 0
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
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local unitDef = UnitDefs[unitDefID]
	if unitDef.name:find("dropship") or unitDef.name:find("dropzone") then
		ClearBuildOptions(unitID, true)
		AddBuildMenu(unitID)
		dropZones[unitID] = teamID
		teamDropZones[teamID] = unitID
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	dropZones[unitID] = nil
	teamDropZones[teamID] = nil
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
end

function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		for _, teamID in pairs(Spring.GetTeamList()) do
			Spring.AddTeamResource(teamID, "metal", 500)
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
