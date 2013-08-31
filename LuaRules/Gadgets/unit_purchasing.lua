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

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local ud = UnitDefs[unitDefID]
	if ud.name:find("dropzone") then -- TODO: cache dropzone unitDefIDs
		local typeString = menuCmdIDs[cmdID]
		if typeString then
			ClearBuildOptions(unitID)
			ShowBuildOptionsByType(unitID, typeString)
			return true
		elseif cmdID < 0 then
			-- TODO: limit count
			-- TODO: check we can afford it
		elseif cmdID == CMD_SEND_ORDER then
			-- TODO: DropshipDelivery() from unit_beaconBuild
			-- TODO: check we can afford the whole lot?
			-- TODO: cooldown - remove all options
			local orderQueue = Spring.GetFullBuildQueue(unitID)
			local cost = 1 -- TODO: track cost
			GG.DropshipDelivery(unitID, teamID, "is_dropship_fx", orderQueue, cost) -- TODO: send dropship of correct side
			Spring.Echo("Sending purchase order for the following:")
			for i, order in ipairs(orderQueue) do
				for orderDefID, count in pairs(order) do
					Spring.Echo(UnitDefs[orderDefID].name, count)
				end
			end
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
