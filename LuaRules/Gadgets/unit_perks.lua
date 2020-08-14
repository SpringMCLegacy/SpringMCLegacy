function gadget:GetInfo()
	return {
		name = "Unit - Perks, Upgrades & Mods",
		desc = "Controls Mexh XP Perks, Outpost Upgrades and Mechbay Mods",
		author = "FLOZi (C. Lawrence)",
		date = "31/03/2013",
		license = "GNU GPL v2",
		layer = 4, -- run after game_radar & unit_purchasing
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
local completeTexts = {
	["perks"] = "Trained",
	["upgrades"] = "Purchased",
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
local appUnits = {} -- [unitID][appType] = true

-- dropzone perks need to be persistent -- TODO: make 'persistent' an appDef property so Aero & Avenger can be persistent too
local dropZoneUpgrades = {} -- dropZoneUpgrades[teamID] = {perk1 = true, perk2 = true, ...}

local appInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")
for appType, defs in pairs(appInclude) do
	for i, appDef in ipairs(defs) do
		local currency = appType == "upgrades" and "C-Bills" or appType == "mods" and "Salvage" or nil -- TODO: would be nice to read cost function name?
		if currency then
			appDef.cmdDesc.tooltip = appDef.cmdDesc.tooltip .. "\n( " .. currency .. " cost: " .. (Spring.IsNoCostEnabled() and 0 or appDef.price) .. " )"
		end
		if appDef.requires then -- assumes prerequisite upgrades are defined first
			appDef.cmdDesc.tooltip = appDef.cmdDesc.tooltip .. "\n[ Requires" .. appDefNames[appDef.requires].cmdDesc.name:gsub("\n", ""):gsub("%s+", " ") .. "]"
		end
		appDefs[appDef.cmdDesc.id] = appDef
		appDefTypes[appDef.cmdDesc.id] = appType
		appDefNames[appDef.name] = appDef
	end
end

-- Checks if apps are affordable and disables those that are not
local function UpdateRemaining(unitID, appType, newLevel, applierID)
	applierID = applierID or unitID
	local appRemaining = false
	for appCmdID, appDef in pairs(appDefs) do
		if appType == appDefTypes[appDef.cmdDesc.id] then -- eww
			if not unitID then -- no mech in mechbay
				EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, appCmdID), {disabled = false, name = appDef.cmdDesc.name})
			elseif unitID then
				if (not currentApps[unitID][appType][appDef.name] or currentApps[unitID][appType][appDef.name] < (appDef.levels or 1)) 
				and validApps[Spring.GetUnitDefID(applierID)][appType][appCmdID] then
					appRemaining = true
					local price = Spring.IsNoCostEnabled() and 0 or appDef.price
					if (newLevel < price) or (appDef.requires and not currentApps[unitID][appType][appDef.requires]) then
						EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, appCmdID), {disabled = true, params = {"C"}})
					else
						EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, appCmdID), {disabled = false, name = appDef.cmdDesc.name})
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

local function UpdateUnitApps(unitID, appType)
	local teamID, _, dead = Spring.GetUnitTeam(unitID)
	local applierID
	if not dead then
		local newLevel
		if appType == "perks" then
			newLevel = Spring.GetUnitExperience(unitID)
			Spring.SetUnitRulesParam(unitID, "perk_xp", math.min(100, 100 * newLevel / 1)) -- TODO: refers to PERK_UNIT_COST from include :(
		elseif appType == "mods" then
			newLevel = GG.GetTeamSalvage(teamID)
			applierID = unitID
			unitID = Spring.GetUnitIsTransporting(unitID)[1]
		elseif appType == "upgrades" then
			newLevel = select(1, Spring.GetTeamResources(teamID, "metal"))
		end
		UpdateRemaining(unitID, appType, newLevel, applierID)
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
				UpdateUnitApps(unitID, appType)
			end
		end
	end
end

local function ApplyAppToUnit(unitID, appType, appDef, cmdID, applierID)
	applierID = applierID or unitID -- default to unitID
	if not currentApps[unitID][appType] then currentApps[unitID][appType] = {} end -- create current aps for mods in mechbay
	if appDef.requires and not currentApps[unitID][appType][appDef.requires] then return false end
	local level = currentApps[unitID][appType][appDef.name] or 0
	if level == (appDef.levels or 1) then return false end -- in case it was issued when multiple were selected
	level = level + 1
	currentApps[unitID][appType][appDef.name] = level
	appDef.applyPerk(unitID, level)
	if level == (appDef.levels or 1) then -- fully trained
		local complete = completeTexts[appType]
		EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, cmdID), {name = appDef.cmdDesc.name .."\n  (" .. complete .. ")", disabled = false})
	else
		local nameString = GG.Pad(appDef.cmdDesc.name, "(" .. level .. " of " .. appDef.levels ..")")
		EditUnitCmdDesc(applierID, FindUnitCmdDesc(applierID, cmdID), {name = nameString})
	end
	appDef.costFunction(unitID, appDef.price)
	UpdateUnitApps(applierID, appType) -- update here too to prevent pause cheating
end		

local function RemoveMod(unitID, appDef, applierID)
	if not currentApps[unitID]["mods"][appDef.name] then
		return false -- mod is not installed
	else
		currentApps[unitID]["mods"][appDef.name] = nil
		appDef.costFunction(unitID, -appDef.price)
		appDef.applyPerk(unitID, 0, true) -- invert
		UpdateUnitApps(applierID, "mods")
		return true
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local appType = appDefTypes[cmdID]
	local rightClick = cmdOptions.right
	-- check that this unit can receive this perk (can be issued the order due to multiple units selected)
	-- ... and that it doesn't already have it
	if appType and validApps[unitDefID][appType][cmdID] then
		local appDef = appDefs[cmdID]
		local applierID
		if appType == "mods" then
			applierID = unitID
			unitID = Spring.GetUnitIsTransporting(unitID)[1]
			if not unitID then return false end
			if rightClick then -- removing mod
				return RemoveMod(unitID, appDef, applierID)
			end
		end
		local success = ApplyAppToUnit(unitID, appType, appDef, cmdID, applierID)
		-- return false for mechs (so command queue is not changed), true otherwise (to clear stack for dropzone?)
		return success and appType ~= "perks"
	end
	-- let all other commands run through this gadget unharmed
	return true
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if validApps[unitDefID] then
		currentApps[unitID] = {}
		appUnits[unitID] = {}
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
		 -- start out with enough XP for one perk
		if cp.baseclass == "mech" then
			Spring.SetUnitRulesParam(unitID, "perk_xp", 100)
			SetUnitExperience(unitID, 1) -- Ach, another reference to XP cost
			currentApps[unitID]["mods"] = {} -- As actually only 'valid' for mechbay
		end
		--[[for perkCmdID, perkDef in pairs(perkDefs) do -- using pairs here means perks aren't in order, use Find?
			if validPerks[unitDefID][perkCmdID] then -- Only add perks valid for this mech
				InsertUnitCmdDesc(unitID, perkDef.cmdDesc)
			end
		end]]
		
		--[[for i, cmdDesc in ipairs(orderedPerks[unitDefID]) do -- enforce order
			InsertUnitCmdDesc(unitID, cmdDesc)
		end]]
		
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
end

else

-- UNSYNCED

end
