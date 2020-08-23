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
		Spring.SetGameRulesParam(name, cmdID)
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
  function gadget:Initialize()
    for name, cmdID in pairs(customCommands.IDs) do
	  --Spring.Echo("Adding cmd to game rules params!", name, cmdID)
      Spring.SetGameRulesParam(name, cmdID)
    end
  end
end

