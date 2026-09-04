function gadget:GetInfo()
	return {
		name		= "Outpost - Mech Bay",
		desc		= "Controls mech bay & salvage",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/20",
		license 	= "GNU GPL v2",
		layer		= 7, -- after perks
		enabled		= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()

-- localisations
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs
local GetUnitDefID 			= Spring.GetUnitDefID
local GetUnitIsTransporting	= Spring.GetUnitIsTransporting
local GetUnitPosition		= Spring.GetUnitPosition
local GetUnitTeam 			= Spring.GetUnitTeam
local GetTeamResources		= Spring.GetTeamResources
local IsNoCostEnabled 		= Spring.IsNoCostEnabled
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitExperience		= Spring.SetUnitExperience
local SetUnitHealth 		= Spring.SetUnitHealth
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam
local UseTeamResource 		= Spring.UseTeamResource
-- UnitScript
-- localised in init so that unit_script has loaded
local CallAsUnit
local GetScriptEnv			

-- UnsyncedCtrl
local SendMessageToTeam		= Spring.SendMessageToTeam

-- GG
local COLOURS 				= GG.GameConstants.colours
local DelayCall				= GG.Delay.DelayCall
local GetCmdID 				= GG.CustomCommands.GetCmdID

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local MECHBAY_ID = UnitDefNames["outpost_mechbay"].id
local CRATE_ID = UnitDefNames["crate"].id

-- Support Vehicle related ------------------------------------------------------------------------------
local CMD_SET_BASE = GG.CustomCommands.GetCmdID("CMD_SET_BASE")
local CMD_RESUPPLY = GG.CustomCommands.GetCmdID("CMD_RESUPPLY")
local CMD_FIELDREPAIR = GG.CustomCommands.GetCmdID("CMD_FIELDREPAIR")

local SUPPORT_DIST = 100

-- Support Shared
local setBaseCmdDesc = {
	id 		= CMD_SET_BASE,
	type	= CMDTYPE.ICON_UNIT,
	name 	= GG.Pad("Assign", "Base", 12),
	action	= "setbase",
	tooltip = "Set the base outpost",
	cursor	= "Guard", -- TODO: custom cursor?
}
GG.setBaseCmdDesc = setBaseCmdDesc

local resupplyCmdDesc = {
	id 		= CMD_RESUPPLY,
	type	= CMDTYPE.ICON_UNIT,
	name 	= GG.Pad("Resupply", "Ammo", 12),
	action	= "resupply",
	tooltip = "Resupply ammunition to a combat unit",
	cursor	= "Resupply",
}

local rtbCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_DEPOSIT"),
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Restock", "Crates", 12),
	action	= "rtb",
	tooltip = "Returns to mechbay to restock to 6 ammo crates",
}

local repairCmdDesc = {
	id 		= CMD_FIELDREPAIR,
	type	= CMDTYPE.ICON_UNIT,
	name 	= GG.Pad("Repair", "Mech", 12),
	action	= "repair",
	tooltip = "Repair a battlemech in the field",
	cursor	= "Repair", -- TODO: custom cursor?
}

-- J-27
local J27_ID = UnitDefNames["j27"].id
local CMD_RESUPPLY = GG.CustomCommands.GetCmdID("CMD_RESUPPLY")
-- Savior
local SAVIOR_ID = UnitDefNames["savior"].id
local CMD_FIELDREPAIR = GG.CustomCommands.GetCmdID("CMD_FIELDREPAIR")

local supportTargets = {} -- supportID = mechID
local supportStates = {} -- 0 = Ready, 1 = Active, 2 = RTB
GG.supportStates = supportStates -- for LUS

local supportCosts = {
	[J27_ID] = tonumber(UnitDefNames["j27"].customParams.price),
	[SAVIOR_ID] = tonumber(UnitDefNames["savior"].customParams.price),
}
local supportDescs = {
	[J27_ID] = {GG.setBaseCmdDesc, rtbCmdDesc, resupplyCmdDesc},
	[SAVIOR_ID] = {GG.setBaseCmdDesc, repairCmdDesc},
}

-- Yard Support Ordering Descs 
local newJ27CmdDesc = {
	id 		= -J27_ID,
	type	= CMDTYPE.ICON,
	--name 	= " New \n J-27",
	action	= "newj27",
	tooltip = GG.GetBuildToolTip(J27_ID, 1, "Build"),
}
local newSaviorCmdDesc = {
	id 		= -SAVIOR_ID,
	type	= CMDTYPE.ICON,
	name 	= " New \n BRV",
	action	= "newsavior",
	tooltip = GG.GetBuildToolTip(SAVIOR_ID, 1, "Build"),
}

-- Command Descriptions
local getOutCmdDesc = {
	id 		= GetCmdID("CMD_MECHBAY_GETOUT"),
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Get","Out"),
	action	= "mechbay_out",
	tooltip = "Emergency unload",
}
local sellMechCmdDesc = {
	id 		= GetCmdID("CMD_MECHBAY_SELLMECH"),
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Sell","Mech","(+C)"),
	action	= "mechbay_out",
	tooltip = "Sells the mech for C-Bills",
}
local scrapMechCmdDesc = {
	id 		= GetCmdID("CMD_MECHBAY_SCRAPMECH"),
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Scrap","Mech", "(+S)"),
	action	= "mechbay_out",
	tooltip = "Scraps the mech for Salvage",
}

-- Variables
-- Mechbay menu
local START_POSITION = 9
local GET_OUT_POSITION = START_POSITION
local SELL_POSITION = START_POSITION + 1
--local SCRAP_POSITION = START_POSITION + 2

local typeStrings = {"structural", "mobility", "tactical", "offensive", "defensive", "omni", "ammo"}
local typeStringAliases = {
	["ammo"] 		= GG.Pad(10,"Special", "Ammo"),
	["mobility"] 	= GG.Pad(10,"Engine", "Mods"), 
	["tactical"] 	= GG.Pad(10,"System", "Mods"), 
	["offensive"] 	= GG.Pad(10,"Weapon", "Mods"),
	["defensive"] 	= GG.Pad(10,"Armour", "Mods"),
	["structural"] 	= GG.Pad(10,"Chassis", "Mods"),
	["omni"]		= GG.Pad(10, "Omni", "Configs"),
}

local currMenu = {}
local menuCmdDescs = {}
local menuCmdIDs = {}
for i, typeString in ipairs(typeStrings) do
	local cmdID = GetCmdID("CMD_MENU_" .. typeString:upper())
	menuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = typeStringAliases[typeString],
		action = 'menu' .. typeString,
		tooltip = "Modify " .. typeStringAliases[typeString]:sub(1, typeStringAliases[typeString]:find("\n")-1) .. " capabilities of the mech",
	}
	menuCmdIDs[cmdID] = typeString
end

local CMD_MENU_OMNI = GetCmdID("CMD_MENU_OMNI")
menuCmdDescs[7].tooltip = "Select omnimech weapon loadout configuration"
--menuCmdDescs[5].disabled = true
--menuCmdDescs[7].hidden = true

-- Mods
local mechBays = {} -- mechBayID = level
GG.mechBays = mechBays
local hiddenMods = {} -- unitDefID = {[i] = true, etc}

-- Omni
local S = {COLOURS.salvage .. "S"}
local EMPTY_TABLE = {}

local omniCache = {} -- unitDefID = unitNameSansConfig
local omniConfigs = {} -- [unitNameSansConfig]["a"] = true
local omniOrder = {"p", "a", "b", "c", "d", "e", "f", "g", "h"} -- TODO: maybe autogen this


local function CheckOmniOptions(unitID, teamID, cmdID)
	local salvage = GG.GetTeamResource(teamID, "salvage")
	local cmdDescs = GetUnitCmdDescs(unitID) or EMPTY_TABLE
	for cmdDescID = 1, #cmdDescs do
		local buildDefID = cmdDescs[cmdDescID].id
		local cmdDesc = cmdDescs[cmdDescID]
		if cmdDesc.id ~= cmdID then
			local currParam = cmdDesc.params[1] or ""
			local sCost
			if buildDefID < 0 then -- a build order
				sCost = IsNoCostEnabled() and 0 or tonumber(UnitDefs[-buildDefID].customParams.omniswapcost or 5)
			end
			if buildDefID < 0 
			and sCost > salvage and (currParam == "" or currParam == S[1]) then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = S})
			else
				if cmdDesc.disabled and currParam == S[1] then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = EMPTY_TABLE})
				end
			end
		end
	end
end

local function ShowOmniMenu(unitID, tOrF)
	for i, cmdDesc in ipairs(GetUnitCmdDescs(unitID)) do
		if cmdDesc.id == CMD_MENU_OMNI then
			EditUnitCmdDesc(unitID, i, {hidden = not tOrF})
		elseif menuCmdIDs[cmdDesc.id] then
			if cmdDesc.action == "menuammo" then
				EditUnitCmdDesc(unitID, i, {hidden = false})
			else
				EditUnitCmdDesc(unitID, i, {hidden = tOrF})
			end
		end
	end
end

local function ShowOmniOptions(unitID, mechDefID, name, tOrF)
	if tOrF then
		for i, letter in ipairs(omniOrder) do
			local cmdDesc = omniConfigs[name][letter]
			if cmdDesc and cmdDesc.id ~= -mechDefID then
				InsertUnitCmdDesc(unitID, cmdDesc)
			end
		end
		CheckOmniOptions(unitID, GetUnitTeam(unitID))
	else
		for config, cmdDesc in pairs(omniConfigs[name]) do
			local i = FindUnitCmdDesc(unitID, cmdDesc.id)
			if i then -- only remove if we find it, otherwise find can be nil but remove still works
				RemoveUnitCmdDesc(unitID, i)
			end
		end
	end
end

local function SetMechBayLevel(unitID, level)
	mechBays[unitID] = level
	if level == 1 then
		for i, cmdDesc in ipairs(menuCmdDescs) do
			InsertUnitCmdDesc(unitID, START_POSITION + 1 +i, cmdDesc) -- +1 for Sell
		end
		local transporting = GetUnitIsTransporting(unitID)
		local mechID = transporting and transporting[1]
		local omni = false
		if mechID then
			omni = omniCache[GetUnitDefID(mechID)] ~= nil
			ShowOmniMenu(unitID, omni)
		end
	elseif level == 2 then -- Enable Support Vehicles
		InsertUnitCmdDesc(unitID, newJ27CmdDesc)
		InsertUnitCmdDesc(unitID, newSaviorCmdDesc)
	elseif level == 3 then -- Harden the mechbay
		--EditUnitCmdDesc(unitID, SCRAP_POSITION, {disabled = false})
	end
end
GG.SetMechBayLevel = SetMechBayLevel

local function ShowModsByType(unitID, modType, mechID)
	local cmdID = modType and GetCmdID("CMD_MENU_" .. modType:upper())
	local mechDefID = mechID and GetUnitDefID(mechID)
	if mechDefID == CRATE_ID then return end
	for i, cmdDesc in ipairs(GetUnitCmdDescs(unitID)) do
		local cmdDescID = cmdDesc.id
		if not mechID then
			local hide = (cmdDescID > 0 -- not a support vehicle
						and GG.appDefTypes[cmdDescID] ~= "upgrades" -- not the upgrade buttons
						and cmdDescID ~= GetCmdID("CMD_MECHBAY_GETOUT")
						and cmdDescID ~= GetCmdID("CMD_MECHBAY_SELLMECH"))
						or 
						(cmdDescID < 0 
						and omniCache[-cmdDescID] ~= nil)
			EditUnitCmdDesc(unitID, i, {hidden = hide})
		elseif cmdDescID == cmdID then
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/selected.png'})
		elseif menuCmdIDs[cmdDescID] and menuCmdIDs[cmdDescID] ~= CMD_MENU_OMNI then 
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/filter.png'})
		elseif GG.appDefTypes[cmdDescID] == "mods" and not hiddenMods[mechDefID][cmdDescID] then
			EditUnitCmdDesc(unitID, i, {hidden = GG.appDefs[cmdDesc.id].menu ~= modType}) -- eww
		elseif cmdDescID < 0 then -- support vehicles
			EditUnitCmdDesc(unitID, i, {hidden = true})
		end
	end
	if mechID and mechBays[unitID] and omniCache[mechDefID] then
		ShowOmniOptions(unitID, mechDefID, omniCache[mechDefID], modType == "omni")
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == MECHBAY_ID then
		local toRemove = {CMD.LOAD_UNITS, CMD.UNLOAD_UNITS}
		for _, cmdID in pairs(toRemove) do
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, cmdID)
			if cmdDescID then
				Spring.RemoveUnitCmdDesc(unitID, cmdDescID)
			end
		end
		InsertUnitCmdDesc(unitID, GET_OUT_POSITION, getOutCmdDesc)
		InsertUnitCmdDesc(unitID, SELL_POSITION, sellMechCmdDesc)
		SetMechBayLevel(unitID, 1)
		ShowModsByType(unitID, "none", nil) -- don't show any mods until a mech gets in
	elseif supportCosts[unitDefID] then
		supportStates[unitID] = 0
		GG.ChangeSupportLance(teamID, unitID, 1)
		GG.ClearDefaultCmds(unitID)
		GG.AddSupportCmds(unitID, supportDescs[unitDefID])
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	mechBays[unitID] = nil
	supportTargets[unitID] = nil
	supportStates[unitID] = nil
	if supportCosts[unitDefID] then
		GG.ChangeSupportLance(teamID, unitID, -1)
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if mechBays[transportID] and mechBays[transportID] >= 1 and unitDefID ~= CRATE_ID then
		-- update mod status for this mech
		GG.UpdateUnitApps(transportID, unitDefID, "mods")
		ShowModsByType(transportID, currMenu[unitID] or "chassis", unitID)
		-- hide irrelevant mods
		for cmdID in pairs(hiddenMods[unitDefID]) do
			EditUnitCmdDesc(transportID, FindUnitCmdDesc(transportID, cmdID), {hidden = true})
		end
		ShowOmniMenu(transportID, omniCache[unitDefID] ~= nil)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if mechBays[transportID] and mechBays[transportID] >= 1 then
		-- reset menu
		if omniCache[unitDefID] then
			ShowOmniMenu(transportID, false)
		end
		GG.UpdateUnitApps(transportID, unitDefID, "mods")
		ShowModsByType(transportID, "none", nil)
	end
end


function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
	if mechBays[unitID] then
		ShowModsByType(unitID, "none", nil)	
	elseif supportCosts[unitDefID] then
		ChangeSupportLance(newTeam, unitID, 1)
		ChangeSupportLance(oldTeam, unitID, -1)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == MECHBAY_ID then
		if cmdID == getOutCmdDesc.id then
			env = GetScriptEnv(unitID)
			if env and env.script and env.script.TransportDrop then
				local transporting = GetUnitIsTransporting(unitID)
				if transporting then
					CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
					return true
				end
			end
			return false
		elseif cmdID == sellMechCmdDesc.id then
			local transporting = GetUnitIsTransporting(unitID)
			if transporting[1] then
				local cBills = UnitDefs[GetUnitDefID(transporting[1])].metalCost * (modOptions and modOptions.sell or 0.75)
				env = GetScriptEnv(unitID)
				CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
				DestroyUnit(transporting[1], false, true)
				AddTeamResource(teamID, "m", cBills)
				GG.PlaySoundForTeam(teamID, "Chaching", 10)
				return true
			end
			return false
		elseif cmdID == scrapMechCmdDesc.id then
			local transporting = Spring.GetUnitIsTransporting(unitID)
			if transporting[1] then
				local salvage = UnitDefs[GetUnitDefID(transporting[1])].customParams.tonnage * (modOptions and modOptions.scrap or 1)
				env = GetScriptEnv(unitID)
				CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
				DestroyUnit(transporting[1], false, true)
				GG.ChangeTeamResource(teamID, "salvage", salvage)
				return true
			end
			return false
		elseif menuCmdIDs[cmdID] then
			env = GetScriptEnv(unitID)
			env.autoGetOut = false or GG.AI_TEAMS[teamID] -- don't disable autoGetOut if it is on an AI team
			currMenu[unitID] = menuCmdIDs[cmdID]
			local mechID = (GetUnitIsTransporting(unitID) or {})[1]
			ShowModsByType(unitID, menuCmdIDs[cmdID], mechID)
			--if mechID and omniCache[GetUnitDefID(mechID)] then
				--ShowOmniOptions(unitID, omniCache[GetUnitDefID(mechID)], cmdID == CMD_MENU_OMNI)
			--end
		elseif cmdID < 0 then 
			local supportCost = supportCosts[-cmdID]
			local transporting = GetUnitIsTransporting(unitID)
			
			if supportCost then -- purchasing a support vehicle
				local cBills = GetTeamResources(teamID, "metal")
				supportCost = Spring.IsNoCostEnabled() and 0 or supportCost
				if cBills >= supportCost then
					local beaconID = Spring.GetUnitRulesParam(unitID, "beaconID")
					local bx, _, bz = GetUnitPosition(beaconID)
					local ux, _, uz = GetUnitPosition(unitID)
					GG.DropshipDelivery(beaconID, unitID, teamID, GG.teamSide[teamID] .. "_bishop", -cmdID, 0, nil, 0, {x = bx-ux, z = bz-uz})
					UseTeamResource(teamID, "m", -supportCost)
					return true
				end
			elseif transporting[1] then  -- an omni config
				local cost = (IsNoCostEnabled() and 0) or tonumber(UnitDefs[-cmdID].customParams.omniswapcost or 5)
				if GG.GetTeamResource(teamID, "salvage") >= cost then
					GG.ChangeTeamResource(teamID, "salvage", -cost)
					local x,y,z = GetUnitPosition(unitID)
					local newID = CreateUnit(-cmdID, x,y,z, 0, teamID, false, false)
					local oldID = transporting[1]
					SetUnitExperience(newID, Spring.GetUnitExperience(oldID))
					SetUnitHealth(newID, Spring.GetUnitHealth(oldID))
					GG.CloneMechApps(oldID, Spring.GetUnitDefID(oldID), newID, -cmdID)
					env = GetScriptEnv(unitID)
					CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
					DestroyUnit(oldID, false, true)
					CallAsUnit(unitID, env.script.TransportPickup, newID)
					ShowModsByType(unitID, currMenu[unitID], newID)
					UseTeamResource(teamID, "energy", UnitDefs[-cmdID].customParams.tonnage)
					CheckOmniOptions(unitID, teamID, cmdID)
				else
					SendMessageToTeam(teamID, "Insufficient salvage!")
					GG.PlaySoundForTeam(teamID, "bb_insufficient_salvage", 1)
				end
			end
		end
	elseif supportCosts[unitDefID] then -- a support vehicle
		local repair = cmdID == CMD_FIELDREPAIR
		local resupply = cmdID == CMD_RESUPPLY 
		if repair or resupply then
			local savior = unitDefID == SAVIOR_ID
			local j27 = unitDefID == J27_ID
			if (repair and savior) or (resupply and j27) then
				if (supportStates[unitID] or 0) > 0 then return false end -- Already active or RTB
				local targetID = cmdParams[1]
				local targetDefID = GetUnitDefID(targetID)
				if GG.mechCache[targetDefID] then
					local x,y,z = Spring.GetUnitBasePosition(targetID)
					Spring.SetUnitMoveGoal(unitID, x, y, z, SUPPORT_DIST)
					supportTargets[unitID] = targetID
					return true
				else
					return false -- not a mech
				end
			else
				return false -- only Savior can FIELDREPAIR, only J27 can RESUPPLY
			end
		elseif cmdID == CMD_SET_BASE then
			local yardID = cmdParams[1]
			if mechBays[yardID] then -- it is a bay, afterall
				GG.AssociateSupport(yardID, teamID, unitID)
				return true
			end
			return false
		end
	end
	return true
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_FIELDREPAIR or cmdID == CMD_RESUPPLY then
		local targetID = supportTargets[unitID]
		if Spring.GetUnitIsDead(targetID) then return true, true end
		if Spring.GetUnitSeparation(unitID, targetID) < SUPPORT_DIST then -- close enough
			if supportStates[unitID] == 0 then -- ensure this only runs once
				supportStates[unitID] = 1
				-- call the unfold anim
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.Deploy)
				-- Savior will stop on return, now we want the target to stop what it is doing and move to the back
				local mechlink = Spring.GetUnitPieceMap(unitID).mechlink
				local x,y,z = Spring.GetUnitPiecePosDir(unitID, mechlink)
				Spring.GiveOrderToUnit(targetID, CMD.LOAD_ONTO, {unitID}, {})
				Spring.SetUnitMoveGoal(targetID, x,y,z, 1)
				GG.Delay.DelayCall(Spring.UnitScript.CallAsUnit, {unitID, env.script.TransportPickup, targetID}, 30 * 5) -- 5 seconds
				-- need some command fallback for that? use load_onto?
			end
			return true, true
		else -- not close enough yet, keep going
			local x,y,z = Spring.GetUnitBasePosition(targetID)
			Spring.SetUnitMoveGoal(unitID, x, y, z, SUPPORT_DIST - 5)
			return true, false
		end
	end
end

function gadget:GameFrame(n)
	if n % 30 == 5 then -- once a second
		for mechBayID, level in pairs(mechBays) do
			CheckOmniOptions(mechBayID, GetUnitTeam(mechBayID))
		end
	end
end

function gadget:Initialize()
	GetScriptEnv = Spring.UnitScript.GetScriptEnv
	CallAsUnit = Spring.UnitScript.CallAsUnit
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	local modInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")["mods"]
	for unitDefID in pairs(GG.mechCache) do
		local unitDef = UnitDefs[unitDefID]
		if unitDef.customParams.omni then
			local config = unitDef.name:sub(-1)
			local name = unitDef.name:sub(1,-2)
			omniCache[unitDefID] = name
			omniConfigs[name] = omniConfigs[name] or {}
			omniConfigs[name][config] = {
				id = -unitDef.id, 
				tooltip = unitDef.humanName .. "\n" .. unitDef.tooltip .. "\n" .. COLOURS.salvage .. "Salvage cost: " .. tonumber(unitDef.customParams.omniswapcost or 5), 
				action = name..config
			}
		end
		hiddenMods[unitDefID] = {} 
		for i, modDef in ipairs(modInclude) do
			-- ...check if the perk is valid and cache the result
			local show = modDef.applyTo(unitDefID)
			if not show then
				hiddenMods[unitDefID][modDef.cmdDesc.id] = true
			end
		end
	end
	Spring.AssignMouseCursor("Resupply", "cursorrearm")
	Spring.SetCustomCommandDrawData(CMD_RESUPPLY, "Resupply", {1,0.7,0.9,0.8}, true)
	Spring.SetCustomCommandDrawData(CMD_FIELDREPAIR, "repair", {1,0.7,0.9,0.8}, true)
end

else
--	UNSYNCED
return false end