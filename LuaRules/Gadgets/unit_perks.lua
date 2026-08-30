function gadget:GetInfo()
	return {
		name = "Unit - Perks, Upgrades & Mods",
		desc = "Controls Mexh XP Perks, Outpost Upgrades and Mechbay Mods",
		author = "FLOZi (C. Lawrence)",
		date = "31/03/2013",
		license = "GNU GPL v2",
		layer = 6, -- run after game_radar & outpost_dropZone & outpost_airCon
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations

-- Synced Read
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs
local GetUnitExperience		= Spring.GetUnitExperience

-- Synced Ctrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local SetUnitExperience		= Spring.SetUnitExperience

-- Unsynced Ctrl

-- Constants
local EMPTY_TABLE = {}
local COLOURS = GG.GameConstants.colours
local completeTexts = {
	["perks"] = "Trained",
	["upgrades"] = "Installed",
	["mods"] = "Applied",
}
local desiredOrder = {"perks", "upgrades", "mods"}

-- Variables
local appDefs = {} -- [appCmdID] = appDef table
GG.appDefs = appDefs
local appDefNames = {} --[appName] = appDef table
local appDefTypes = {} --[appCmdID] = appType
GG.appDefTypes = appDefTypes
local validApps = {} -- [unitDefID][appType] = {appCmdID = true, etc}
local orderedApps = {} -- unitDefID = {cmdDesc1, cmdDesc2, ...} -- TODO: get rid of need for this by just using the include directly which is already in order
local currentApps = {} --[unitID][appType] = {app1 = true, app2 = true, ...}}
local currentModCounts = {} -- [unitID] = count 
local MAX_MODS = 6
local appUnits = {} -- [unitID][appType] = true
local appUnitDefIDs = {} -- [unitID] = unitDefID

local incompatible = {} -- [unitID][modName] = true

-- dropzone perks need to be persistent -- TODO: make 'persistent' an appDef property so Aero & Avenger can be persistent too
local dropZoneUpgrades = {} -- dropZoneUpgrades[teamID] = {perk1 = true, perk2 = true, ...}


local function BuildToolTip(appType, appDef, unitDefPrice)
	local currency = appType == "upgrades" and (COLOURS.cbills .. "C-Bills") or appType == "mods" and (COLOURS.salvage .. "Salvage") or nil -- TODO: would be nice to read cost function name?
	local tooltip = appDef.cmdDesc.tooltip
	if appDef.requires then -- assumes prerequisite upgrades are defined first
		tooltip = tooltip .. "\n[ Requires" .. appDefNames[appDef.requires].cmdDesc.name:gsub("\n", ""):gsub("%s+", " ") .. "]"
	end
	if currency then
		local price = appDef.price or unitDefPrice
		if not price then return tooltip end
		tooltip = tooltip .. "\n( " .. currency .. " cost: " .. price .. COLOURS.white .. " )"
	end
	return tooltip
end

local appInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")
local modCostsPerUnitDef = {}
for appType, defs in pairs(appInclude) do
	for i, appDef in ipairs(defs) do
		appDef.cmdDesc.tooltip = BuildToolTip(appType, appDef)
		appDefs[appDef.cmdDesc.id] = appDef
		appDefTypes[appDef.cmdDesc.id] = appType
		appDefNames[appDef.name] = appDef
		if appType == "mods" then
			modCostsPerUnitDef[appDef.name] = {}
		end
	end
end

-- loop again for conflicts as all must be laoded
for i, appDef in ipairs(appInclude.mods) do
	if appDef.incompatible then
		local conflicts = ""
		for _, modName in pairs(appDef.incompatible) do
			--Spring.Echo(appDef.name, modName, appDefNames[modName])
			conflicts = conflicts .. appDefNames[modName].cmdDesc.name:gsub("\n", ""):gsub("%s+", " ") .. ","
		end
		appDef.cmdDesc.tooltip = appDef.cmdDesc.tooltip .. "\n{ Incompatible with" .. conflicts .. "}"
	end
end

-- Checks if apps are affordable and disables those that are not
local function UpdateRemaining(unitID, unitDefID, appType, newLevel, applierID)
	applierID = applierID or unitID
	local appRemaining = false
	for appCmdID, appDef in pairs(appDefs) do
		if appType == appDefTypes[appDef.cmdDesc.id] then -- eww
			if not unitID then -- no mech in mechbay
				EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, appCmdID), {disabled = false, name = appDef.cmdDesc.name})
			elseif unitID and currentApps[unitID] then
				if (not currentApps[unitID][appType][appDef.name] or currentApps[unitID][appType][appDef.name] < (appDef.levels or 1)) 
				and validApps[Spring.GetUnitDefID(applierID)][appType][appCmdID] then
					local cmdDescPos = FindUnitCmdDesc(applierID, appCmdID)
					if not cmdDescPos then return end
					appRemaining = true
					local price = Spring.IsNoCostEnabled() and 0 or appDef.price
					if price and appDef.applyTo and appDef.applyTo(unitDefID) then
						modCostsPerUnitDef[appDef.name][unitDefID] = price
					elseif unitDefID and appDef.applyTo and appDef.applyTo(unitDefID) and appDef.priceFunction then
						price = Spring.IsNoCostEnabled() and 0 or modCostsPerUnitDef[appDef.name][unitDefID]
						if not price then -- first time for this unitDefID
							price = appDef.priceFunction(unitDefID)
							modCostsPerUnitDef[appDef.name][unitDefID] = price
						end
						EditUnitCmdDesc(applierID, cmdDescPos, {tooltip = BuildToolTip(appType, appDef, price)})
					end
					if (newLevel < (price or -1))
					or (appDef.requires and not currentApps[unitID][appType][appDef.requires]) then
						EditUnitCmdDesc(applierID, cmdDescPos, {disabled = true,})
					elseif appType == "mods" then -- reset name if no longer applied
						if currentModCounts[unitID] == MAX_MODS and not appDef.noLimit then
							EditUnitCmdDesc(applierID, cmdDescPos, {disabled = true, name = GG.Pad(10, "Fully", "Modded")})
						elseif incompatible[unitID] and incompatible[unitID][appDef.name] then
							EditUnitCmdDesc(applierID, cmdDescPos, {name = appDef.cmdDesc.name .."\n  (Conflict)"})
						else
							EditUnitCmdDesc(applierID, cmdDescPos, {disabled = false, name = appDef.cmdDesc.name})
						end
					else
						EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, appCmdID), {disabled = false,})
					end
				elseif appType == "mods" -- a mech re-entering mechbay
				and currentApps[unitID][appType][appDef.name] == 1 then -- with an applied mod
					EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, appCmdID), {name = appDef.cmdDesc.name .."\n  (" .. completeTexts[appType] .. ")", disabled = false})
				end
			end
		end
	end
	if not appRemaining and appType == "perks" then
		Spring.SetUnitRulesParam(unitID, "perk_fully", 1)
	end
end

local function UpdateUnitApps(unitID, unitDefID, appType)
	local teamID, _, dead = Spring.GetUnitTeam(unitID)
	local applierID
	if teamID and not dead then
		local newLevel
		if appType == "perks" then
			newLevel = Spring.GetUnitExperience(unitID)
			Spring.SetUnitRulesParam(unitID, "perk_xp", math.min(100, 100 * newLevel / GG.PERK_XP_COST))
		elseif appType == "mods" then
			newLevel = GG.GetTeamResource(teamID, "salvage")
			applierID = unitID
			unitID = (Spring.GetUnitIsTransporting(unitID) or EMPTY_TABLE)[1]
			if unitID then unitDefID = Spring.GetUnitDefID(unitID) end -- does this mean it was all a wasted effort anyway?
		elseif appType == "upgrades" then
			newLevel = select(1, Spring.GetTeamResources(teamID, "metal"))
		end
		UpdateRemaining(unitID, unitDefID, appType, newLevel, applierID)
	end
end
GG.UpdateUnitApps = UpdateUnitApps

function gadget:Initialize()
	-- Support /luarules reload
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	
	for unitDefID, unitDef in pairs(UnitDefs) do
		for appType, defs in pairs(appInclude) do
			for i, appDef in ipairs(defs) do
				-- ...check if the app is valid and cache the result
				local valid = appDef.valid(unitDefID)
				if valid then
					if not validApps[unitDefID] then -- first time
						validApps[unitDefID] = {} 
					end
					if not validApps[unitDefID][appType] then -- first time with this appType
						validApps[unitDefID][appType] = {} 
					end
					--Spring.Echo("Valid perk for", unitDef.name, appType, appDef.name)
					validApps[unitDefID][appType][appDef.cmdDesc.id] = valid
					--[[if not orderedPerks[unitDefID] then
						orderedPerks[unitDefID] = {}
					end
					table.insert(orderedPerks[unitDefID], perkDef.cmdDesc)]]
				end
			end
		end
	end
end

function gadget:GameFrame(n)
	if n % 15 == 0 then
		for unitID, unitAppTypes in pairs(appUnits) do
			for appType in pairs(unitAppTypes) do
				UpdateUnitApps(unitID, appUnitDefIDs[unitID], appType)
			end
		end
	end
end

local function RemoveMod(unitID, unitDefID, appDef, applierID)
	if not currentApps[unitID]["mods"][appDef.name] then
		return false -- mod is not installed
	elseif appDef.locked then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_battlemech_mod_integrated", 1)
		return false
	else
		currentApps[unitID]["mods"][appDef.name] = nil
		currentModCounts[unitID] = currentModCounts[unitID] - (appDef.noLimit and 0 or 1)
		appDef.costFunction(unitID, -(appDef.price or appDef.priceFunction(unitDefID)))
		appDef.applyPerk(unitID, 0, true) -- invert
		for _, modName in pairs(appDef.incompatible or EMPTY_TABLE) do -- assumes only mods can be incompatible
			incompatible[unitID][modName] = nil -- assumes if A and B are incompatible with C, then A and B are incompatible
		end
		UpdateUnitApps(applierID, unitDefID, "mods")
		Spring.RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, appDef.cmdDesc.id)) -- remove from 'View Mods' panel
		Spring.SetUnitRulesParam(unitID, appDef.name, false)
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_battlemech_mod_removed", 1)
		return true
	end
end

local function ApplyAppToUnit(unitID, unitDefID, appType, appDef, cmdID, applierID, free)
	if not currentApps[unitID][appType] then currentApps[unitID][appType] = {} end -- create current aps for mods in mechbay
	if appDef.requires and not currentApps[unitID][appType][appDef.requires] then return false end
	if appType == "mods" and not appDef.noLimit and currentModCounts[unitID] == MAX_MODS then return false end
	local level = currentApps[unitID][appType][appDef.name] or 0
	if level == (appDef.levels or 1) then return false end -- in case it was issued when multiple were selected
	-- Play sounds
	if appDef.sound then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), appDef.sound, 1)
	elseif appType == "upgrades" then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_" .. UnitDefs[unitDefID].name .. "_upgraded", 1)
	elseif appType == "perks" then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_battlemech_perked", 1)
	elseif appType == "mods" then
		local conflicted = false
		for _, modName in pairs(appDef.incompatible or EMPTY_TABLE) do -- assumes only mods can be incompatible
			incompatible[unitID][modName] = true
			conflicted = conflicted or RemoveMod(unitID, unitDefID, appDefNames[modName], applierID)
		end
		-- need to make a copy that is hidden by default as it is added after unit_mechCommands sorts out the menu...
		local desc = appDef.cmdDesc
		desc.hidden = true
		InsertUnitCmdDesc(unitID, desc)
		if applierID then -- Special case to add to mech's 'View Mods' menu page, don't play the sound
			GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), conflicted and "bb_battlemech_modded_conflicted" or "bb_battlemech_modded", 1)
		end
		currentModCounts[unitID] = (currentModCounts[unitID] or 0) + (appDef.noLimit and 0 or 1)
	end
	level = level + 1
	currentApps[unitID][appType][appDef.name] = level
	appDef.applyPerk(unitID, level) -- needs to come after any incompatible mods are removed so ammo switches work
	Spring.SetUnitRulesParam(unitID, appDef.name, true)
	if cmdID then
		local mechDefID = Spring.GetUnitDefID(unitID)
		applierID = applierID or unitID -- default to unitID
		if level == (appDef.levels or 1) then -- fully trained
			local complete = completeTexts[appType]
			EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, cmdID), {name = appDef.cmdDesc.name .."\n  (" .. complete .. ")", disabled = false})
		else
			local nameString = GG.Pad(appDef.cmdDesc.name, "(" .. level .. " of " .. appDef.levels ..")")
			EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, cmdID), {name = nameString})
		end
		if not free then
			local price = (Spring.IsNoCostEnabled() and 0) or appDef.price or modCostsPerUnitDef[appDef.name][mechDefID]
			appDef.costFunction(unitID, price)
		end
		UpdateUnitApps(applierID, unitDefID, appType) -- update here too to prevent pause cheating
	end
end		


local function CloneMechApps(oldID, oldUnitDefID, newID, newUnitDefID)
	-- clone perks
	for name, level in pairs(currentApps[oldID]["perks"]) do
		local appDef = appDefNames[name]
		for i = 1, level do
			ApplyAppToUnit(newID, newUnitDefID, "perks", appDef, appDef.cmdDesc.id, nil, true)
		end
	end
	-- remove and refund ammo
	for name, level in pairs(currentApps[oldID]["mods"]) do
		if name:find("ammo") then -- don't remove e.g. doubleheatsinks
			RemoveMod(oldID, oldUnitDefID, appDefNames[name], Spring.GetUnitTransporter(oldID))
		end
	end
end
GG.CloneMechApps = CloneMechApps

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local appType = appDefTypes[cmdID]
	local rightClick = cmdOptions.right
	-- check that this unit can receive this perk (can be issued the order due to multiple units selected)
	-- ... and that it doesn't already have it
	if appType 
	and validApps[unitDefID] -- unit can receive apps of any sort
	and validApps[unitDefID][appType] -- unit can recieve apps of this type
	and validApps[unitDefID][appType][cmdID] then -- unit can receive this specific app
		local appDef = appDefs[cmdID]
		local applierID
		if appType == "mods" then
			applierID = unitID
			unitID = (Spring.GetUnitIsTransporting(unitID) or EMPTY_TABLE)[1]
			if not unitID then return false end
			if rightClick then -- removing mod
				return RemoveMod(unitID, unitDefID, appDef, applierID)
			end
		end
		local success = ApplyAppToUnit(unitID, unitDefID, appType, appDef, cmdID, applierID)
		-- return false for mechs (so command queue is not changed), true otherwise (to clear stack for dropzone?)
		return success and appType ~= "perks"
	end
	-- let all other commands run through this gadget unharmed
	return true
end

function AddApps(unitID, unitDefID)
	currentApps[unitID] = {}
	appUnits[unitID] = {}
	appUnitDefIDs[unitID] = unitDefID
	for i, appType in ipairs(desiredOrder) do
		if validApps[unitDefID][appType] then
			currentApps[unitID][appType] = {}
			appUnits[unitID][appType] = true
			for i, appDef in ipairs(appInclude[appType]) do
				if validApps[unitDefID][appType][appDef.cmdDesc.id] then
					InsertUnitCmdDesc(unitID, appDef.cmdDesc)
				end
			end
		end
	end
end
GG.AddApps = AddApps

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if validApps[unitDefID] then
		 -- start out with enough XP for one perk
		if cp.baseclass == "mech" then
			Spring.SetUnitRulesParam(unitID, "perk_xp", 100)
			SetUnitExperience(unitID, GG.PERK_XP_COST)
			currentApps[unitID]["mods"] = {} -- As actually only 'valid' for mechbay
			incompatible[unitID] = {}
			-- install pre-loaded mods
			local mods = table.unserialize(cp.mods)
			for i, modName in pairs(mods) do
				if appDefNames[modName] then -- only accept existing mod, some are in defs for future implementation
					ApplyAppToUnit(unitID, unitDefID, "mods", appDefNames[modName])
				end
			end
		else
		-- outposts handled here, mechs handed in unit_mechCommands.lua
			AddApps(unitID, unitDefID)
		end
		-- check if unit is a DZ and team DZ has previously been perked
		if GG.DROPZONE_IDS[unitDefID] and dropZoneUpgrades[teamID] then
			table.copy(dropZoneUpgrades[teamID], currentApps[unitID]["upgrades"])
			for appName in pairs(currentApps[unitID]["upgrades"]) do
				local appDef = appDefNames[appName]
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, appDef.cmdDesc.id), {name = appDef.cmdDesc.name .."\n  (Purchased)", disabled = true})
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if GG.DROPZONE_IDS[unitDefID] then
		dropZoneUpgrades[teamID] = {}
		table.copy(currentApps[unitID]["upgrades"], dropZoneUpgrades[teamID])
	end
	currentApps[unitID] = nil
	appUnits[unitID] = nil
	appUnitDefIDs[unitID] = nil
end

else
-- UNSYNCED
return false end