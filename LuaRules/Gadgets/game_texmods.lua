--------------------------------------------------------------------------------
-- MCL team paint-scheme selection / validation
-- Author: zvero + ChatGPT
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "MCL TexMods",
		desc = "Validates and publishes per-team paint-scheme selections",
		author = "zvero + ChatGPT",
		date = "2026-09-04",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true,
	}
end

if not gadgetHandler:IsSyncedCode() then
	return false
end

local TEXMOD = VFS.Include("LuaRules/Configs/mcl_texmods.lua", nil, VFS.ZIP)
local sideData = TEXMOD.LoadSideData()
local texmodData = TEXMOD.LoadTexmodData()
local MSG_PREFIX = "MCLTEXMOD|"
local DEBUG_MSG_PREFIX = "MCLTEXMODALL|"
local Echo = Spring.Echo
local SetTeamRulesParam = Spring.SetTeamRulesParam
local GetPlayerInfo = Spring.GetPlayerInfo
local GetTeamList = Spring.GetTeamList

local function GetTeamSide(teamID)
	return TEXMOD.GetEffectiveTeamSide(teamID, sideData)
end

local function SetTeamTexmod(teamID, texmod)
	texmod = TEXMOD.NormalizeTexmod(texmod)
	SetTeamRulesParam(teamID, TEXMOD.TEAM_RULE_PARAM, texmod, {public = true})
end

local function ParseRequest(msg)
	if type(msg) ~= "string" then
		return nil
	end
	if msg:sub(1, #DEBUG_MSG_PREFIX) == DEBUG_MSG_PREFIX then
		return msg:sub(#DEBUG_MSG_PREFIX + 1), true
	end
	if msg:sub(1, #MSG_PREFIX) == MSG_PREFIX then
		return msg:sub(#MSG_PREFIX + 1), false
	end
	return nil
end

function gadget:Initialize()
	for _, teamID in ipairs(GetTeamList()) do
		SetTeamTexmod(teamID, TEXMOD.DEFAULT_TEXMOD)
	end
	Echo("[MCL TexMods] Initialized. Default paint scheme for every team is 'Team'.")
end

function gadget:RecvLuaMsg(msg, playerID)
	local requested, debugAll = ParseRequest(msg)
	if requested == nil then
		return false
	end

	if #requested > 96 or requested:find("[^%w_%-]") then
		Echo("[MCL TexMods] Rejected malformed texmod request from player " .. tostring(playerID) .. "; using Team.")
		return true
	end

	local playerName, _, spectator, teamID = GetPlayerInfo(playerID, false)
	if not playerName or spectator or teamID == nil then
		return true
	end

	if debugAll then
		local cheatsEnabled = Spring.IsCheatingEnabled and Spring.IsCheatingEnabled() or false
		if not cheatsEnabled then
			Echo("[MCL TexMods] Rejected /texmodall selection from " .. tostring(playerName) .. "; cheats are not enabled.")
			return true
		end

		local known, canonical = TEXMOD.IsKnownTexmod(requested, texmodData)
		if not known then
			Echo("[MCL TexMods] Rejected unknown debug texmod '" .. tostring(requested) .. "'.")
			return true
		end

		SetTeamTexmod(teamID, canonical)
		Echo(string.format(
			"[MCL TexMods] DEBUG: team %d selected paint scheme '%s' via %s (/texmodall).",
			teamID, canonical, playerName
		))
		return true
	end

	local side, sideEntry, sideSource = GetTeamSide(teamID)
	local allowed, canonical = TEXMOD.IsAllowedTexmod(side, requested, texmodData, sideEntry)
	if not allowed then
		Echo(string.format(
			"[MCL TexMods] Rejected texmod '%s' for team %d (%s via %s); not present in Gamedata/texmods.lua for that faction. Falling back to Team.",
			tostring(requested), teamID, tostring(side), tostring(sideSource)
		))
		SetTeamTexmod(teamID, TEXMOD.DEFAULT_TEXMOD)
		return true
	end

	SetTeamTexmod(teamID, canonical)
	Echo(string.format(
		"[MCL TexMods] Team %d (%s via %s) selected paint scheme '%s' via %s.",
		teamID, tostring(side), tostring(sideSource), canonical, playerName
	))
	return true
end
