function gadget:GetInfo()
	return {
		name		= "Outpost - Mech Bay",
		desc		= "Controls mech bay & salvage",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/20",
		license 	= "GNU GPL v2",
		layer		= 5, -- after perks
		enabled	= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()

-- localisations
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitPosition		= Spring.GetUnitPosition
local GetTeamResources		= Spring.GetTeamResources
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local CreateUnit			= Spring.CreateUnit
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc
local SetUnitRulesParam		= Spring.SetUnitRulesParam
local SetTeamRulesParam		= Spring.SetTeamRulesParam
local UseTeamResource 		= Spring.UseTeamResource

-- GG
local DelayCall				 = GG.Delay.DelayCall

-- Constants
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()
local MECHBAY_ID = UnitDefNames["outpost_mechbay"].id
local PICKUP_DIST = 50

-- Command Descriptions
local getOutCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_MECHBAY_GETOUT"),
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Get","Out"),
	action	= "mechbay_out",
	tooltip = "Emergency unload",
}
local sellMechCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_MECHBAY_SELLMECH"),
	type	= CMDTYPE.ICON,
	name 	= GG.Pad("Sell","Mech","(+C)"),
	action	= "mechbay_out",
	tooltip = "Sells the mech for C-Bills",
}
local scrapMechCmdDesc = {
	id 		= GG.CustomCommands.GetCmdID("CMD_MECHBAY_SCRAPMECH"),
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
local SCRAP_POSITION = START_POSITION + 2

local typeStrings = {"ammo", "mobility", "tactical", "offensive", "defensive", "omni"}
local typeStringAliases = {
	["ammo"] 		= GG.Pad(10,"Ammo", "Mods"),
	["mobility"] 	= GG.Pad(10,"Mobility", "Mods"), 
	["tactical"] 	= GG.Pad(10,"Tactical", "Mods"), 
	["offensive"] 	= GG.Pad(10,"Offense", "Mods"),
	["defensive"] 	= GG.Pad(10,"Defense", "Mods"),
	["omni"]		= GG.Pad(10, "Omni", "Configs"),
}

local currMenu = {}
local menuCmdDescs = {}
local menuCmdIDs = {}
for i, typeString in ipairs(typeStrings) do
	local cmdID = GG.CustomCommands.GetCmdID("CMD_MENU_" .. typeString:upper())
	menuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = typeStringAliases[typeString],
		action = 'menu' .. typeString,
		tooltip = "Modify " .. typeStringAliases[typeString]:sub(1, typeStringAliases[typeString]:find("\n")-1) .. " capabilities of the mech",
	}
	menuCmdIDs[cmdID] = typeString
end

local CMD_MENU_OMNI = GG.CustomCommands.GetCmdID("CMD_MENU_OMNI")
menuCmdDescs[5].tooltip = "Select omnimech weapon loadout configuration"
menuCmdDescs[5].disabled = true
menuCmdDescs[5].hidden = true

-- Mods
local mechBays = {} -- mechBayID = level
local hiddenMods = {} -- unitDefID = {[i] = true, etc}

-- Omni
local omniCache = {} -- unitDefID = unitNameSansConfig
local omniConfigs = {} -- [unitNameSansConfig]["a"] = true
local omniOrder = {"p", "a", "b", "c", "d", "e", "f", "g", "h"} -- TODO: maybe autogen this

-- Salvage pickup
local pieces = {}
local names = {
	["pelvis"] = true,
	["lupperarm"] = true,
	["rupperarm"] = true,
	["turret"] = true,
}

local teamSalvages = {} -- teamID = salvageAmount
local salvageSources = {} -- featureID = {x,z}
local salvageCache = {} -- featureDefID = true
local salvageArray = {} -- [1] = featureDefID1, ...
local unitPinataLevels = {} -- unitID = 0 or 1 or 2 or 3

local function PinataLevel(unitID, delta)
	if delta then
		unitPinataLevels[unitID] = unitPinataLevels[unitID] + delta
	end
	return unitPinataLevels[unitID] or 0 -- incase of non-mech killer
end
GG.PinataLevel = PinataLevel

local function GetTeamSalvage(teamID)
	return teamSalvages[teamID] or 0
end
GG.GetTeamSalvage = GetTeamSalvage

local function ChangeTeamSalvage(teamID, delta)
	teamSalvages[teamID] = (teamSalvages[teamID] or 0) + delta
	Spring.SetTeamRulesParam(teamID, "SALVAGE", teamSalvages[teamID])
end
GG.ChangeTeamSalvage = ChangeTeamSalvage

local S = {"S"}
local EMPTY_TABLE = {}

local function CheckOmniOptions(unitID, teamID, cmdID)
	local salvage = GetTeamSalvage(teamID)
	local cmdDescs = Spring.GetUnitCmdDescs(unitID) or EMPTY_TABLE
	for cmdDescID = 1, #cmdDescs do
		local buildDefID = cmdDescs[cmdDescID].id
		local cmdDesc = cmdDescs[cmdDescID]
		if cmdDesc.id ~= cmdID then
			local currParam = cmdDesc.params[1] or ""
			local sCost
			if buildDefID < 0 then -- a build order
				sCost = Spring.IsNoCostEnabled() and 0 or tonumber(UnitDefs[-buildDefID].customParams.omniswapcost or 5)
			end
			if buildDefID < 0 
			and sCost > salvage and (currParam == "" or currParam == "S") then
				EditUnitCmdDesc(unitID, cmdDescID, {disabled = true, params = S})
			else
				if cmdDesc.disabled and currParam == "S" then
					EditUnitCmdDesc(unitID, cmdDescID, {disabled = false, params = EMPTY_TABLE})
				end
			end
		end
	end
end

local function ShowOmniMenu(unitID, tOrF)
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id == CMD_MENU_OMNI then
			EditUnitCmdDesc(unitID, i, {hidden = not tOrF})
		elseif menuCmdIDs[cmdDesc.id] then
			if cmdDesc.action ~= "menuammo" then
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
		CheckOmniOptions(unitID, Spring.GetUnitTeam(unitID))
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
		EditUnitCmdDesc(unitID, SELL_POSITION, {disabled = true}) -- disable Sell
		EditUnitCmdDesc(unitID, SCRAP_POSITION, {disabled = true}) -- disable Scrap
		for i, cmdDesc in ipairs(menuCmdDescs) do
			InsertUnitCmdDesc(unitID, START_POSITION + 2 +i, cmdDesc)
		end
		local transporting = Spring.GetUnitIsTransporting(unitID)
		local mechID = transporting and transporting[1]
		local omni = false
		if mechID then
			omni = omniCache[Spring.GetUnitDefID(mechID)] ~= nil
		end
		ShowOmniMenu(unitID, omni)
	--elseif level == 3 then
		EditUnitCmdDesc(unitID, START_POSITION + 7, {disabled = false})
	elseif level == 2 then -- Enable Sell
		EditUnitCmdDesc(unitID, SELL_POSITION, {disabled = false})
	elseif level == 3 then -- Enable Scrap
		EditUnitCmdDesc(unitID, SCRAP_POSITION, {disabled = false})
	end
end
GG.SetMechBayLevel = SetMechBayLevel

local function ShowModsByType(unitID, modType, mechID)
	local cmdID = modType and GG.CustomCommands.GetCmdID("CMD_MENU_" .. modType:upper())
	local mechDefID = mechID and Spring.GetUnitDefID(mechID)
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		local cmdDescID = cmdDesc.id
		if cmdDescID == cmdID then
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/selected.png',})
		elseif menuCmdIDs[cmdDescID] then 
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/filter.png',})
		elseif GG.appDefTypes[cmdDescID] == "mods" then
			if mechID and not hiddenMods[mechDefID][cmdDescID] then
				EditUnitCmdDesc(unitID, i, {hidden = GG.appDefs[cmdDesc.id].menu ~= modType}) -- eww
			elseif not mechID then -- hide all mods if no mech loaded
				EditUnitCmdDesc(unitID, i, {hidden = true})
			end
		end
	end
	if mechBays[unitID] == 3 and omniCache[mechDefID] then
		ShowOmniOptions(unitID, mechDefID, omniCache[mechDefID], modType == "omni")
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == MECHBAY_ID then
		InsertUnitCmdDesc(unitID, GET_OUT_POSITION, getOutCmdDesc)
		InsertUnitCmdDesc(unitID, SELL_POSITION, sellMechCmdDesc)
		InsertUnitCmdDesc(unitID, SCRAP_POSITION, scrapMechCmdDesc)
		SetMechBayLevel(unitID, 1)
		ShowModsByType(unitID, "none", nil) -- don't show any mods until the ability is unlocked
	elseif GG.mechCache[unitDefID] then -- a mech
		unitPinataLevels[unitID] = 0
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if mechBays[transportID] and mechBays[transportID] >= 2 then
		-- update mod status for this mech
		GG.UpdateUnitApps(transportID, "mods")
		ShowModsByType(transportID, currMenu[unitID], unitID)
		-- hide irrelevant mods
		for cmdID in pairs(hiddenMods[unitDefID]) do
			--Spring.Echo("Hiding2", UnitDefs[unitDefID].name, GG.appDefs[cmdID].name)
			EditUnitCmdDesc(transportID, FindUnitCmdDesc(transportID, cmdID), {hidden = true})
		end
		ShowOmniMenu(transportID, omniCache[unitDefID] ~= nil)
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if mechBays[transportID] and mechBays[transportID] >= 2 then -- TODO: check it is level 2
		-- reset menu
		GG.UpdateUnitApps(transportID, "mods")
		ShowModsByType(transportID, "none", unitID)
		ShowOmniMenu(transportID, false)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if unitDefID == MECHBAY_ID then
		if cmdID == getOutCmdDesc.id then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			if env and env.script and env.script.TransportDrop then
				local transporting = Spring.GetUnitIsTransporting(unitID)
				if transporting then
					Spring.UnitScript.CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
					return true
				end
			end
			return false
		elseif cmdID == sellMechCmdDesc.id then
			local transporting = Spring.GetUnitIsTransporting(unitID)
			if transporting[1] then
				local cBills = UnitDefs[Spring.GetUnitDefID(transporting[1])].metalCost * (modOptions and modOptions.sell or 0.75)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
				Spring.DestroyUnit(transporting[1], false, true)
				AddTeamResource(teamID, "m", cBills)
				return true
			end
			return false
		elseif cmdID == scrapMechCmdDesc.id then
			local transporting = Spring.GetUnitIsTransporting(unitID)
			if transporting[1] then
				local salvage = UnitDefs[Spring.GetUnitDefID(transporting[1])].customParams.tonnage * (modOptions and modOptions.scrap or 1)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
				Spring.DestroyUnit(transporting[1], false, true)
				ChangeTeamSalvage(teamID, salvage)
				return true
			end
			return false
		elseif menuCmdIDs[cmdID] then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.autoGetOut = false or GG.AI_TEAMS[teamID] -- don't disable autoGetOut if it is on an AI team
			currMenu[unitID] = menuCmdIDs[cmdID]
			local mechID = (Spring.GetUnitIsTransporting(unitID) or {})[1]
			ShowModsByType(unitID, menuCmdIDs[cmdID], mechID)
			if mechID and omniCache[Spring.GetUnitDefID(mechID)] then
				--ShowOmniOptions(unitID, omniCache[Spring.GetUnitDefID(mechID)], cmdID == CMD_MENU_OMNI)
			end
		elseif cmdID < 0 then -- a omni config
			local transporting = Spring.GetUnitIsTransporting(unitID)
			if transporting[1] then
				local cost = (Spring.IsNoCostEnabled() and 0) or tonumber(UnitDefs[-cmdID].customParams.omniswapcost or 5)
				if GetTeamSalvage(teamID) >= cost then
					ChangeTeamSalvage(teamID, -cost)
					local x,y,z = Spring.GetUnitPosition(unitID)
					local newID = Spring.CreateUnit(-cmdID, x,y,z, 0, teamID, false, false)
					Spring.SetUnitExperience(newID, Spring.GetUnitExperience(transporting[1]))
					GG.CloneMechApps(transporting[1], newID)
					env = Spring.UnitScript.GetScriptEnv(unitID)
					Spring.UnitScript.CallAsUnit(unitID, env.script.TransportDrop, transporting[1])
					Spring.DestroyUnit(transporting[1], false, true)
					Spring.UnitScript.CallAsUnit(unitID, env.script.TransportPickup, newID)
					ShowModsByType(unitID, currMenu[unitID], newID)
					CheckOmniOptions(unitID, teamID, cmdID)
				else
					Spring.SendMessageToTeam(teamID, "Insufficient salvage!")
				end
			end
		end
	end
	return true
end

function gadget:FeatureCreated(featureID, allyTeamID)
	if salvageCache[Spring.GetFeatureDefID(featureID)] then
		local x,y,z = Spring.GetFeaturePosition(featureID)
		salvageSources[featureID] = {
			["x"] = x, 
			["z"] = z,
			["amount"] = 1, -- TODO: customparam
		}
	end
end

function gadget:FeatureDestroyed(featureID)
	salvageSources[featureID] = nil
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	--local name = Spring.GetProjectileName(proID)
	local weap, piece = Spring.GetProjectileType(proID)
	if piece and not GG.Beacons[proOwnerID] --[[and names[name]] then pieces[proID] = true end
	--Spring.Echo("PC", proID, proOwnerID, weaponID, name, defID, weap, piece)
end
	
function gadget:ProjectileDestroyed(proID)
	if pieces[proID] then
		local x,_,z = Spring.GetProjectilePosition(proID)
		Spring.CreateFeature(salvageArray[math.random(#salvageArray)], x,Spring.GetGroundHeight(x,z),z)
		pieces[proID] = nil
	end
end

function gadget:GameFrame(n)
	if n % 10 == 0 then -- 3 times a second
		for featureID, info in pairs(salvageSources) do
			local units = Spring.GetUnitsInCylinder(info.x, info.z, PICKUP_DIST)
			if units[1] then
				local unitDefID = Spring.GetUnitDefID(units[1])
				if GG.mechCache[unitDefID] then
					local teamID = Spring.GetUnitTeam(units[1])
					ChangeTeamSalvage(teamID, info.amount)
					Spring.DestroyFeature(featureID)
				end
			end
		end
		for mechBayID, level in pairs(mechBays) do
			if level == 3 then
				CheckOmniOptions(mechBayID, Spring.GetUnitTeam(mechBayID))
			end
		end
	end
end

function gadget:Initialize()
	Script.SetWatchWeapon(-1, true) -- pieces
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	for featureDefID, featureDef in pairs(FeatureDefs) do
		if featureDef.name:find("salvage") then -- TODO: customparam
			salvageCache[featureDefID] = true
			table.insert(salvageArray, featureDefID)
		end
	end
	local modInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")["mods"]
	--for unitDefID, unitDef in pairs(UnitDefs) do
	for unitDefID in pairs(GG.mechCache) do
		local unitDef = UnitDefs[unitDefID]
		if unitDef.customParams.omni then
			local config = unitDef.name:sub(-1)
			local name = unitDef.name:sub(1,-2)
			omniCache[unitDefID] = name
			omniConfigs[name] = omniConfigs[name] or {}
			omniConfigs[name][config] = {
				id = -unitDef.id, 
				tooltip = unitDef.humanName .. "\n" .. unitDef.tooltip .. "\nCost: " .. tonumber(unitDef.customParams.omniswapcost or 5) .. " Salvage", 
				action = name..config
			}
		end
		hiddenMods[unitDefID] = {} 
		for i, modDef in ipairs(modInclude) do
			-- ...check if the perk is valid and cache the result
			local show = modDef.applyTo(unitDefID)
			if not show then
				--Spring.Echo("Hiding", unitDef.name, modDef.name)
				hiddenMods[unitDefID][modDef.cmdDesc.id] = true
			end
		end
	end
end

else
--	UNSYNCED

end
