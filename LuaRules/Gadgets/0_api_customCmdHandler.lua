function gadget:GetInfo()
  return {
    name      = "Custom Command Handler",
    desc      = "Generates Custom Command IDs",
    author    = "FLOZi (C. Lawrence)",
    date      = "21 January 2012",
    license   = "GNU GPL v2",
    layer     = -math.huge,
    enabled   = true,
  }
end

-- DRAGONS BE HERE! Do not rename this file!
-- The filename of this file starts with a 0 to ensure that it is loaded before all other gadgets
-- Note that loading order != execution order, which is what layer in GetInfo controls!

-- Setup
local GameConstants = VFS.Include("gamedata/GameConstants.lua", nil, VFS.ZIP)
GG.GameConstants = GameConstants

GG.CommandCosts = {} -- CommandCosts[cmdID] = cBillCost
GG.CustomCommands = {}
GG.CustomCommands.numCmds = 0
GG.CustomCommands.IDs = {}
GG.CustomCommands.names = {}

_G.CustomCommandIDs = {}

-- localisations
local floor 			= math.floor
local format			= string.format
-- Constants
local BASE_CMD_ID = 1001
-- Variables
local customCommands = GG.CustomCommands

-- TODO: move Pad to a api_menus, (needs to be loaded before others hence being in here :/ )
local PAD_LENGTH = 12
local function PadString(input, length)
	while input:len() < (length or PAD_LENGTH) do
		input = " " .. input .. " "
	end
	return input
end
local function Pad(...)
	local arg = {...}
	local output = ""
	local length = (type (arg[1]) == type(1) and arg[1]) or nil
	for i, v in ipairs(arg) do
		if type (v) == "string" then
			output = output .. PadString(v, length) .. "\n"
		end
	end
	return output:sub(1,-2) -- remove trailing newline
end
GG.Pad = Pad

local function GetCmdID(name, cost)
	if (not customCommands) then
		customCommands = GG.CustomCommands
	end
	local cmdID = customCommands.IDs[name]
	if not cmdID then
		cmdID = BASE_CMD_ID + customCommands.numCmds
		GG.CommandCosts[cmdID] = cost or 0
		customCommands.numCmds = customCommands.numCmds + 1
		customCommands.IDs[name] = cmdID
		customCommands.names[cmdID] = name
		_G.CustomCommandIDs[name] = cmdID
		gadgetHandler:RegisterCMDID(cmdID)
		--Spring.SetGameRulesParam(name, cmdID)
		--Spring.Echo(name, cmdID)
	end
	return cmdID, cost or 0
end
GG.CustomCommands.GetCmdID = GetCmdID

local function FramesToMinutesAndSeconds(frames)
	local gameSecs = floor(frames / 30)
	local minutes = format("%02d",  floor(gameSecs / 60))
	local seconds = format("%02d", gameSecs % 60)
	return minutes, seconds
end
GG.FramesToMinutesAndSeconds = FramesToMinutesAndSeconds

if (gadgetHandler:IsSyncedCode()) then
	local COLOURS = GG.GameConstants.colours
	
	local function GetBuildToolTip(unitDefID, discount, action)
		local ud = UnitDefs[unitDefID]
		local weaponTooltip = ud.weapons[1] and "" or ": n/a "
		local tooltip = action .. ": " .. ud.humanName .. " - " .. ud.tooltip .. weaponTooltip .. "\n" 
						.. "Health " .. ud.health .. "\n"
						.. COLOURS.cbills .. "C-Bills cost " .. tonumber(ud.customParams.price) * discount .. "\n"
		if ud.customParams.tonnage then
			tooltip = tooltip .. COLOURS.tonnage .. "Tonnage cost " .. tonumber(ud.customParams.tonnage)
		end
		return tooltip
	end
	GG.GetBuildToolTip = GetBuildToolTip -- for outpost_salvageYard.lua, outpost_mechBay

	function gadget:Initialize()
		for name, cmdID in pairs(customCommands.IDs) do
			--Spring.Echo("Adding cmd to game rules params!", name, cmdID)
			Spring.SetGameRulesParam(name, cmdID)
		end
	end
end

