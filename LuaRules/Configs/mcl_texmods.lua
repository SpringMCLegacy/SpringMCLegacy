--------------------------------------------------------------------------------
-- MCL TexMods shared configuration/helpers
-- Author: zvero + ChatGPT
--------------------------------------------------------------------------------

local M = {
	DEFAULT_TEXMOD = "Team",
	TEAM_RULE_PARAM = "mcl_texmod",
	START_UNIT_RULE_PARAM = "startUnit",
	BOT_BUDDY_RULE_PARAM = "bot_buddy",
	BOT_BUDDY_MODOPTION = "texmod_botbuddy",
	BOT_BUDDY_DEFAULT = false,
	UNIT_PARAM = "texmod",
	UNIT_PARAM_ENABLE = "player",
	UNIT_PARAM_DISABLE = "none",
	RECHECK_FRAMES = 15,
	TEXMOD_DATA_PATH = "Gamedata/texmods.lua",

	FORCE_ENABLE_UNIT_NAMES = {
		-- ["example_support_vehicle"] = true,
	},

	FORCE_DISABLE_UNIT_NAMES = {
	},
}

local function Lower(value)
	return type(value) == "string" and value:lower() or ""
end

local function SideDisplayName(data, fallback)
	if type(data) ~= "table" then
		return fallback or ""
	end
	return data.shortName or data.name or data.sideName or data.caseName or fallback or ""
end

local function SideStartUnitName(data)
	if type(data) ~= "table" then
		return nil
	end
	return data.startunit or data.startUnit or data.startUnitName or data.startunitname
end

function M.IsTruthy(value, default)
	if value == nil then
		return default == true
	end
	if value == true or value == 1 then
		return true
	end
	if value == false or value == 0 then
		return false
	end
	local text = Lower(tostring(value))
	return text == "1" or text == "true" or text == "yes" or text == "on" or text == "enabled"
end

function M.NormalizeTexmod(value)
	if type(value) ~= "string" or value == "" then
		return M.DEFAULT_TEXMOD
	end
	if Lower(value) == Lower(M.DEFAULT_TEXMOD) then
		return M.DEFAULT_TEXMOD
	end
	return value
end

-- sidedata is retained only for resolving MCL's direct-launch startUnit back to
-- the faction selected by the existing faction wheel. Paint-scheme membership is
-- no longer read from sidedata; all paint definitions come from Gamedata/texmods.lua.
function M.LoadSideData()
	local ok, data = pcall(VFS.Include, "gamedata/sidedata.lua", {})
	if not ok or type(data) ~= "table" then
		return {}
	end
	return data
end

function M.LoadTexmodData()
	local ok, data = pcall(VFS.Include, M.TEXMOD_DATA_PATH, {})
	if not ok or type(data) ~= "table" then
		return {}
	end
	return data
end

local function SideMatches(data, sideName)
	if type(data) ~= "table" or type(sideName) ~= "string" then
		return false
	end
	local wanted = Lower(sideName)
	return Lower(data.shortName) == wanted
		or Lower(data.name) == wanted
		or Lower(data.sideName) == wanted
		or Lower(data.caseName) == wanted
end

function M.GetSideEntry(sideName, sideData)
	sideData = sideData or M.LoadSideData()
	for _, data in pairs(sideData) do
		if SideMatches(data, sideName) then
			return data
		end
	end
	return nil
end

function M.GetSideEntryFromStartUnit(startUnitDefID, sideData)
	sideData = sideData or M.LoadSideData()
	startUnitDefID = tonumber(startUnitDefID)
	local unitDef = startUnitDefID and UnitDefs and UnitDefs[startUnitDefID]
	local unitName = unitDef and unitDef.name
	if type(unitName) ~= "string" or unitName == "" then
		return nil
	end

	local wanted = Lower(unitName)
	for _, data in pairs(sideData) do
		local startUnitName = SideStartUnitName(data)
		if type(startUnitName) == "string" and Lower(startUnitName) == wanted then
			return data
		end
	end
	return nil
end

function M.GetEffectiveTeamSide(teamID, sideData)
	sideData = sideData or M.LoadSideData()
	if teamID == nil then
		return "", nil, "none"
	end

	local startUnitDefID = Spring.GetTeamRulesParam
		and Spring.GetTeamRulesParam(teamID, M.START_UNIT_RULE_PARAM)
	local startEntry = M.GetSideEntryFromStartUnit(startUnitDefID, sideData)
	if startEntry then
		return SideDisplayName(startEntry), startEntry, "startUnit"
	end

	local side = ""
	if Spring.GetTeamInfo then
		local _, _, _, _, teamSide = Spring.GetTeamInfo(teamID, false)
		side = teamSide or ""
	end
	local sideEntry = M.GetSideEntry(side, sideData)
	if sideEntry then
		return SideDisplayName(sideEntry, side), sideEntry, "teamInfo"
	end
	return side, nil, "teamInfo"
end

local function TexmodEntryMatches(factionKey, sideName)
	return type(factionKey) == "string"
		and type(sideName) == "string"
		and Lower(factionKey) == Lower(sideName)
end

function M.GetTexmodEntry(sideName, texmodData, sideEntry)
	texmodData = texmodData or M.LoadTexmodData()
	local names = {}
	local function AddName(value)
		if type(value) == "string" and value ~= "" then
			names[#names + 1] = value
		end
	end

	AddName(sideName)
	if type(sideEntry) == "table" then
		AddName(sideEntry.shortName)
		AddName(sideEntry.name)
		AddName(sideEntry.sideName)
		AddName(sideEntry.caseName)
	end

	for factionKey, entry in pairs(texmodData) do
		for n = 1, #names do
			if TexmodEntryMatches(factionKey, names[n]) then
				return entry, factionKey
			end
		end
	end
	return nil
end

local function GetTexmodID(value)
	if type(value) == "string" then
		return value
	end
	if type(value) == "table" then
		return value.id or value.name
	end
	return nil
end

local function AppendTexmod(result, seen, value)
	local id = GetTexmodID(value)
	if type(id) ~= "string" or id == "" then
		return
	end
	local normalized = M.NormalizeTexmod(id)
	local key = Lower(normalized)
	if not seen[key] then
		seen[key] = true
		result[#result + 1] = normalized
	end
end

local function AppendTexmodList(result, seen, texmods)
	if type(texmods) == "string" then
		AppendTexmod(result, seen, texmods)
	elseif type(texmods) == "table" then
		-- Preserve legacy/array entries first, then append keyed debug IDs in a
		-- deterministic order. The current Gamedata/texmods.lua uses keyed IDs.
		for i = 1, #texmods do
			AppendTexmod(result, seen, texmods[i])
		end

		local keyed = {}
		for key, value in pairs(texmods) do
			if type(key) == "string" and (value == true or type(value) == "table") then
				keyed[#keyed + 1] = key
			end
		end
		table.sort(keyed, function(a, b) return Lower(a) < Lower(b) end)
		for i = 1, #keyed do
			AppendTexmod(result, seen, keyed[i])
		end
	end
end

function M.GetAllowedTexmods(sideName, texmodData, sideEntry)
	local result = {M.DEFAULT_TEXMOD}
	local seen = {[Lower(M.DEFAULT_TEXMOD)] = true}
	local entry = M.GetTexmodEntry(sideName, texmodData, sideEntry)
	AppendTexmodList(result, seen, entry and entry.texmods)
	return result
end

function M.GetAllTexmods(texmodData)
	texmodData = texmodData or M.LoadTexmodData()
	local result = {M.DEFAULT_TEXMOD}
	local seen = {[Lower(M.DEFAULT_TEXMOD)] = true}
	local factions = {}
	for factionKey in pairs(texmodData) do
		if type(factionKey) == "string" then
			factions[#factions + 1] = factionKey
		end
	end
	table.sort(factions, function(a, b) return Lower(a) < Lower(b) end)
	for i = 1, #factions do
		local entry = texmodData[factions[i]]
		if type(entry) == "table" then
			AppendTexmodList(result, seen, entry.texmods)
		end
	end
	return result
end

function M.IsAllowedTexmod(sideName, requested, texmodData, sideEntry)
	requested = M.NormalizeTexmod(requested)
	local wanted = Lower(requested)
	local allowed = M.GetAllowedTexmods(sideName, texmodData, sideEntry)
	for i = 1, #allowed do
		if Lower(allowed[i]) == wanted then
			return true, allowed[i]
		end
	end
	return false, M.DEFAULT_TEXMOD
end

function M.IsKnownTexmod(requested, texmodData)
	requested = M.NormalizeTexmod(requested)
	local wanted = Lower(requested)
	local all = M.GetAllTexmods(texmodData)
	for i = 1, #all do
		if Lower(all[i]) == wanted then
			return true, all[i]
		end
	end
	return false, M.DEFAULT_TEXMOD
end

function M.GetTexmodDisplayName(texmod, texmodData)
	texmod = M.NormalizeTexmod(texmod)
	if texmod == M.DEFAULT_TEXMOD then
		return M.DEFAULT_TEXMOD
	end

	texmodData = texmodData or M.LoadTexmodData()
	local wanted = Lower(texmod)
	for _, factionEntry in pairs(texmodData) do
		local texmods = type(factionEntry) == "table" and factionEntry.texmods
		if type(texmods) == "table" then
			-- Current keyed format: DebugID = { display = "Player Name" }
			for id, entry in pairs(texmods) do
				if type(id) == "string" and Lower(id) == wanted then
					if type(entry) == "table" and type(entry.display) == "string" and entry.display ~= "" then
						return entry.display
					end
					return id
				end
			end

			-- Backward-compatible array entries.
			for i = 1, #texmods do
				local entry = texmods[i]
				local id = GetTexmodID(entry)
				if type(id) == "string" and Lower(id) == wanted then
					if type(entry) == "table" and type(entry.display) == "string" and entry.display ~= "" then
						return entry.display
					end
					return id
				end
			end
		end
	end

	return texmod
end

function M.BotBuddyTexmodsEnabled()
	local options = Spring.GetModOptions and Spring.GetModOptions() or {}
	return M.IsTruthy(options and options[M.BOT_BUDDY_MODOPTION], M.BOT_BUDDY_DEFAULT)
end

function M.UnitDefExplicitEligibility(unitDef)
	if not unitDef then
		return false
	end
	local name = unitDef.name
	if name and M.FORCE_DISABLE_UNIT_NAMES[name] then
		return false
	end

	local cp = unitDef.customParams or {}
	local mode = Lower(cp[M.UNIT_PARAM])
	if mode == M.UNIT_PARAM_DISABLE then
		return false
	end
	if name and M.FORCE_ENABLE_UNIT_NAMES[name] then
		return true
	end
	if mode == M.UNIT_PARAM_ENABLE then
		return true
	end
	return Lower(cp.baseclass) == "mech"
end

function M.UnitDefExplicitlyDisabled(unitDef)
	if not unitDef then
		return true
	end
	if unitDef.name and M.FORCE_DISABLE_UNIT_NAMES[unitDef.name] then
		return true
	end
	local cp = unitDef.customParams or {}
	return Lower(cp[M.UNIT_PARAM]) == M.UNIT_PARAM_DISABLE
end

return M
