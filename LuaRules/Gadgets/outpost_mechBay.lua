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

-- localisations
--SyncedRead
local GetGameFrame			= Spring.GetGameFrame
local GetUnitPosition		= Spring.GetUnitPosition
local GetTeamResources		= Spring.GetTeamResources
--SyncedCtrl
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
	name 	= GG.Pad("Sell","Mech"),
	action	= "mechbay_out",
	tooltip = "Sells the mech for C-Bills",
}

-- Variables
-- Mechbay menu
local typeStrings = {"mobility", "tactical", "offensive", "defensive", "ammo"}
local typeStringAliases = {
	["mobility"] 	= GG.Pad(10,"Mobility", "Mods"), 
	["tactical"] 	= GG.Pad(10,"Tactical", "Mods"), 
	["offensive"] 	= GG.Pad(10,"Offense", "Mods"),
	["defensive"] 	= GG.Pad(10,"Defense", "Mods"),
	["ammo"] 		= GG.Pad(10,"Ammo", "Mods"),
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
		tooltip = typeStringAliases[typeString]:gsub("%s+\n", " ") .. " capabilities of the mech",
	}
	menuCmdIDs[cmdID] = typeString
end

-- Mods
local mechBays = {} -- mechBayID = level
local hiddenMods = {} -- unitDefID = {[i] = true, etc}

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

local function SetMechBayLevel(unitID, level)
	mechBays[unitID] = level
	if level == 2 then
		for i, cmdDesc in ipairs(menuCmdDescs) do
			InsertUnitCmdDesc(unitID, 10+i, cmdDesc)
		end
	end
end
GG.SetMechBayLevel = SetMechBayLevel

local function ShowModsByType(unitID, modType, mechID)
	local cmdID = modType and GG.CustomCommands.GetCmdID("CMD_MENU_" .. modType:upper())
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		local cmdDescID = cmdDesc.id
		if cmdDescID == cmdID then
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/selected.png',})
		elseif menuCmdIDs[cmdDescID] then 
			EditUnitCmdDesc(unitID, i, {texture = '',})
		elseif GG.appDefTypes[cmdDescID] == "mods" then
			if mechID and not hiddenMods[Spring.GetUnitDefID(mechID)][cmdDescID] then
				EditUnitCmdDesc(unitID, i, {hidden = GG.appDefs[cmdDesc.id].menu ~= modType}) -- eww
			elseif not mechID then -- hide all mods if no mech loaded
				EditUnitCmdDesc(unitID, i, {hidden = true})
			end
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	if unitDefID == MECHBAY_ID then
		--Spring.Echo(FindUnitCmdDesc(unitID, GG.CustomCommands.GetCmdID("PERK_MECHBAY_2")))
		InsertUnitCmdDesc(unitID, 9, sellMechCmdDesc)
		InsertUnitCmdDesc(unitID, 10, getOutCmdDesc)
		SetMechBayLevel(unitID, 1)
		ShowModsByType(unitID, "none", nil)
	elseif GG.mechCache[unitDefID] then -- a mech
		unitPinataLevels[unitID] = 0
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if mechBays[transportID] >= 2 then
		-- update mod status for this mech
		GG.UpdateUnitApps(transportID, "mods")
		ShowModsByType(transportID, currMenu[unitID], unitID)
		-- hide irrelevant mods
		for cmdID in pairs(hiddenMods[unitDefID]) do
			--Spring.Echo("Hiding2", UnitDefs[unitDefID].name, GG.appDefs[cmdID].name)
			EditUnitCmdDesc(transportID, FindUnitCmdDesc(transportID, cmdID), {hidden = true})
		end
	end
end

function gadget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if mechBays[transportID] >= 2 then -- TODO: check it is level 2
		-- reset menu
		GG.UpdateUnitApps(transportID, "mods")
		ShowModsByType(transportID, "none", nil)
		-- show all mods -- TODO: should no longer be required when menu is done as that will unhide
		--[[for cmdID in pairs(hiddenMods[unitDefID]) do
			EditUnitCmdDesc(transportID, FindUnitCmdDesc(transportID, cmdID), {hidden = false})
		end]]
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
		elseif menuCmdIDs[cmdID] then
			currMenu[unitID] = menuCmdIDs[cmdID]
			local mechID = (Spring.GetUnitIsTransporting(unitID) or {})[1]
			ShowModsByType(unitID, menuCmdIDs[cmdID], mechID)
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
	local name = Spring.GetProjectileName(proID)
	local weap, piece = Spring.GetProjectileType(proID)
	if piece and names[name] then pieces[proID] = true end
	--Spring.Echo("PC", proID, proOwnerID, weaponID, name, defID, weap, piece)
end
	
function gadget:ProjectileDestroyed(proID)
	if pieces[proID] then
		local x,y,z = Spring.GetProjectilePosition(proID)
		Spring.CreateFeature(salvageArray[math.random(#salvageArray)], x,y,z)
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
