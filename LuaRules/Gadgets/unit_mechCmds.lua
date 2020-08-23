function gadget:GetInfo()
	return {
		name		= "Unit - Mech Commands",
		desc		= "Mech Command Menu",
		author		= "FLOZi (C. Lawrence)",
		date		= "10/08/20", -- keep on truckin'
		license 	= "GNU GPL v2",
		layer		= -4, -- needs to run before unit_perks
		enabled	= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead
local AreTeamsAllied		= Spring.AreTeamsAllied
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local RemoveUnitCmdDesc		= Spring.RemoveUnitCmdDesc

-- Constants
-- function for toggling weapon status via gui
local CMD_WEAPON_TOGGLE = GG.CustomCommands.GetCmdID("CMD_WEAPON_TOGGLE")

-- CMD.FIRE_STATE
local fireStateCmdDesc = {
	id = CMD.FIRE_STATE,
	type   = CMDTYPE.ICON_MODE,
	action = 'firestate',
	tooltip = "Set the unit's rules of engagement",
	params = {2, GG.Pad("Hold", "Fire"), GG.Pad("Return", "Fire"), GG.Pad(14,"Fire", "At", "Will")}
	--tooltip = "",
}
-- CMD.MOVE_STATE
local moveStateCmdDesc = {
	id = CMD.MOVE_STATE,
	type   = CMDTYPE.ICON_MODE,
	action = 'movestate',
	tooltip = "Set the unit's movement rules",
	params = {0, GG.Pad("Hold", "Position"), GG.Pad("Maneuver"), GG.Pad("Roam")}
	--tooltip = "",
}
-- CMD.ONOFF
local onOffCmdDesc = {
	id 	= CMD.ONOFF,
	type   = CMDTYPE.ICON_MODE,
	action = 'onoff',
	tooltip = "Turning Sensors off makes the unit harder to detect by enemy sensors",
	params	= {1, GG.Pad("Radar", "Off"), GG.Pad("Radar", "On")},
	--tooltip = "",
}

-- CMD.MOVE
local moveCmdDesc = {
	id 	= CMD.MOVE,
	type   = CMDTYPE.ICON_MAP,
	action = "move",
	cursor = "Move",
	tooltip = "Move to destination",
	name   = GG.Pad("Move")
	--tooltip = "",
}
-- CMD_TURN
local turnCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_TURN"),
	type = CMDTYPE.ICON_MAP,
	name = GG.Pad("Turn"),
	action = "turn",
	tooltip = "Turn to face a location",
	cursor = "Patrol",
}
-- CMD.STOP
local stopCmdDesc = {
	id 	= CMD.STOP,
	type   = CMDTYPE.ICON,
	action = "stop",
	tooltip = "Stop all actions",
	name   = GG.Pad("Stop")
	--tooltip = "",
}

-- CMD.ATTACK
local attackCmdDesc = {
	id 	= CMD.ATTACK,
	type   = CMDTYPE.ICON_UNIT_OR_MAP,
	action = "attack",
	cursor = "Attack",
	tooltip = "Attack the target or targetted location",
	name   = GG.Pad("Attack")
	--tooltip = "",
}
-- CMD.FIGHT
local fightCmdDesc = {
	id 	= CMD.FIGHT,
	type   = CMDTYPE.ICON_MAP,
	action = "fight",
	cursor = "Fight",
	tooltip = "Move towards target destination, stopping to engage any enemies along the way",
	name   = GG.Pad("Fight")
	--tooltip = "",
}
-- CMD.GUARD
local guardCmdDesc = {
	id 	= CMD.GUARD,
	type   = CMDTYPE.ICON_UNIT,
	action = "guard",
	cursor = "Guard",
	tooltip = "Follow and guard targeted friendly unit",
	name   = GG.Pad("Guard")
	--tooltip = "",
}

-- CMD_FLUSH
local flushCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_FLUSH"),
	action = 'flush',
	name = GG.Pad("Flush","Coolant"),
	tooltip = 'Rapidly cool down the unit',
	queueing = false,
	disabled = true,
}
-- CMD_JUMP
local jumpCmdDesc = {
  id      = GG.CustomCommands.GetCmdID("CMD_JUMP"),
  type    = CMDTYPE.ICON_MAP,
  name    = GG.Pad("Jump"),
  cursor  = 'Jump',
  action  = 'jump',
  tooltip = 'Jump to selected position',
}
-- CMD_MASC
local mascCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_MASC"),
	action = 'masc',
	--name = '  MASC Off  ',
	tooltip = 'Activate MASC accelerated sprint',
	type	= CMDTYPE.ICON_MODE,
	params	= {0, GG.Pad("MASC Off"), GG.Pad("MASC On")},
	cursor	= "run",
}

-- CMD_BLANK
local blankCmdDesc = {
  id      = GG.CustomCommands.GetCmdID("CMD_BLANK"),
  type    = CMDTYPE.ICON,
  tooltip = 'This space intentionally left blank',
}
local blank2CmdDesc = {
  id      = GG.CustomCommands.GetCmdID("CMD_BLANK2"),
  type    = CMDTYPE.ICON,
  tooltip = 'This space intentionally left blank',
}

-- CMD_PERK_1..N

local CMDS = {CMD.FIRE_STATE, CMD.MOVE_STATE, CMD.ONOFF, CMD.MOVE, CMD.STOP, CMD.ATTACK, CMD.FIGHT, CMD.GUARD, CMD.PATROL, CMD.WAIT, CMD.REPEAT}

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if GG.mechCache[unitDefID] then
		-- first remove all the default command descriptions
		for _, cmd in pairs(CMDS) do
			RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmd))
		end
		-- then re-add them in our desired order
		InsertUnitCmdDesc(unitID, fireStateCmdDesc)
		InsertUnitCmdDesc(unitID, moveStateCmdDesc)
		InsertUnitCmdDesc(unitID, onOffCmdDesc)
		InsertUnitCmdDesc(unitID, moveCmdDesc)
		InsertUnitCmdDesc(unitID, turnCmdDesc)
		InsertUnitCmdDesc(unitID, stopCmdDesc)
		InsertUnitCmdDesc(unitID, attackCmdDesc)
		InsertUnitCmdDesc(unitID, fightCmdDesc)
		InsertUnitCmdDesc(unitID, guardCmdDesc)
		InsertUnitCmdDesc(unitID, flushCmdDesc)
		if GG.jumpers[unitDefID] then
			InsertUnitCmdDesc(unitID, jumpCmdDesc)
		else
			InsertUnitCmdDesc(unitID, blankCmdDesc)
		end
		if GG.mascUnitDefs[unitDefID] then
			InsertUnitCmdDesc(unitID, mascCmdDesc)
		else
			InsertUnitCmdDesc(unitID, blank2CmdDesc)
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_WEAPON_TOGGLE then
		env = Spring.UnitScript.GetScriptEnv(unitID)
		Spring.UnitScript.CallAsUnit(unitID, env.ToggleWeapon, cmdParams[1]) -- 1st param is weaponNum
		return false
	end
	-- everything else
	return true
end

function gadget:Initialize()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED

end
