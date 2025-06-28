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
local GetUnitDefID			= Spring.GetUnitDefID
local ValidUnitID			= Spring.ValidUnitID
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
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
	params = {2, GG.Pad(14,"Hold", "Fire"), GG.Pad(14,"Return", "Fire"), GG.Pad(14,"Fire", "At", "Will")}
	--tooltip = "",
}
-- CMD.MOVE_STATE
local moveStateCmdDesc = {
	id = CMD.MOVE_STATE,
	type   = CMDTYPE.ICON_MODE,
	action = 'movestate',
	tooltip = "Set the unit's movement rules",
	params = {0, GG.Pad(10,"Hold", "Position"), GG.Pad(10,"Maneuver"), GG.Pad(10,"Roam")}
	--tooltip = "",
}
-- CMD.ONOFF
local onOffCmdDesc = {
	id 	= CMD.ONOFF,
	type   = CMDTYPE.ICON_MODE,
	action = 'onoff',
	tooltip = "Turning Sensors off makes the unit harder to detect by enemy sensors",
	params	= {1, GG.Pad(10,"Radar", "Off"), GG.Pad(10,"Radar", "On")},
	--tooltip = "",
}
GG.onOffCmdDesc = onOffCmdDesc
local stealthParams = {1, GG.Pad(10,"Radar", "Off"), GG.Pad(10,"Radar", "On"), GG.Pad(10,"Stealth")}
GG.stealthParams = stealthParams

-- CMD.MOVE
local moveCmdDesc = {
	id 	= CMD.MOVE,
	type   = CMDTYPE.ICON_MAP,
	action = "move",
	cursor = "Move",
	tooltip = "Move to destination",
	name   = GG.Pad(10,"Move")
	--tooltip = "",
}
-- CMD_TURN
local turnCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_TURN"),
	type = CMDTYPE.ICON_MAP,
	name = GG.Pad(10,"Turn"),
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
	name   = GG.Pad(10,"Stop")
	--tooltip = "",
}

-- CMD.ATTACK
local attackCmdDesc = {
	id 	= CMD.ATTACK,
	type   = CMDTYPE.ICON_UNIT_OR_MAP,
	action = "attack",
	cursor = "Attack",
	tooltip = "Attack the target or targetted location",
	name   = GG.Pad(10,"Attack")
	--tooltip = "",
}
-- CMD.FIGHT
local fightCmdDesc = {
	id 	= CMD.FIGHT,
	type   = CMDTYPE.ICON_MAP,
	action = "fight",
	cursor = "Fight",
	tooltip = "Move towards target destination, stopping to engage any enemies along the way",
	name   = GG.Pad(10,"Fight")
	--tooltip = "",
}
-- CMD.GUARD
local guardCmdDesc = {
	id 	= CMD.GUARD,
	type   = CMDTYPE.ICON_UNIT,
	action = "guard",
	cursor = "Guard",
	tooltip = "Follow and guard targeted friendly unit",
	name   = GG.Pad(10,"Guard")
	--tooltip = "",
}
-- CMD.PATROL
local patrolCmdDesc = {
	id 	= CMD.PATROL,
	type   = CMDTYPE.ICON_UNIT,
	action = "patrol",
	cursor = "Patrol",
	tooltip = "Repeatly patrol between waypoints",
	name   = GG.Pad(10,"Patrol")
	--tooltip = "",
}
-- CMD_JUMP
local jumpCmdDesc = {
  id      = GG.CustomCommands.GetCmdID("CMD_JUMP"),
  type    = CMDTYPE.ICON_MAP,
  name    = GG.Pad(10,"Jump"),
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
	params	= {0, GG.Pad(10,"MASC Off"), GG.Pad(10,"MASC On")},
	cursor	= "run",
	hidden = true,
}

-- CMD_UNIT_SET_TARGET
local unitSetTargetCircleCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_UNIT_SET_TARGET"),
	type = CMDTYPE.ICON_UNIT_OR_AREA,
	name = GG.Pad(10,'Set', 'Target'), --extra spaces center the 'Set' text
	action = 'settarget',
	cursor = 'settarget',
	tooltip = tooltipText,
	hidden = false,
}
-- CMD_UNIT_CANCEL_TARGET
local unitCancelTargetCmdDesc = {
	id = GG.CustomCommands.GetCmdID("CMD_UNIT_CANCEL_TARGET"),
	type = CMDTYPE.ICON,
	name = GG.Pad(10,'Cancel', 'Target'),
	action = 'canceltarget',
	tooltip = 'Removes top priority target, if set',
	hidden = false,
}

-- CMD_PERK_1..N

local menuCmdDescs = {}
local menuCmdIDs = {}
local ignoredCmdDescs = {}

local menuStrings = {"issueorder", "pilotperks", "viewmods"}
local menuStringAliases = { -- whitespace is to try and equalise resulting font size
	["issueorder"] 		= GG.Pad(10,"Issue", "Orders"),
	["pilotperks"] 		= GG.Pad(10,"Pilot", "Perks"),
	["viewmods"] 		= GG.Pad(10,"View", "Mods"),
}
local currMenu = {}

for i, menuString in ipairs(menuStrings) do
	local cmdID = GG.CustomCommands.GetCmdID("CMD_MENU_" .. menuString:upper())
	menuCmdDescs[i] = {
		id     = cmdID,
		type   = CMDTYPE.ICON,
		name   = menuStringAliases[menuString],
		action = 'menu' .. menuString,
		tooltip = "Switch menu to " .. menuStringAliases[menuString]:gsub("%s+\n", " "),
		texture = 'bitmaps/ui/filter.png',
	}
	menuCmdIDs[cmdID] = menuString
	ignoredCmdDescs[cmdID] = 1
end

local CMDS_TO_REMOVE = {CMD.FIRE_STATE, CMD.MOVE_STATE, CMD.ONOFF, CMD.MOVE, CMD.STOP, CMD.ATTACK, CMD.FIGHT, CMD.GUARD, CMD.PATROL, CMD.REPEAT}
local CMD_DESCS_TO_ADD = {
	fireStateCmdDesc, moveStateCmdDesc, onOffCmdDesc,
	moveCmdDesc, turnCmdDesc, stopCmdDesc,
	attackCmdDesc, unitSetTargetCircleCmdDesc, unitCancelTargetCmdDesc,
	fightCmdDesc, guardCmdDesc, patrolCmdDesc,
	jumpCmdDesc,
	mascCmdDesc,
}
local wantedCmdDescs = {}
for i, cmdDesc in ipairs(CMD_DESCS_TO_ADD) do
	wantedCmdDescs[cmdDesc.id] = true
end

local function AddMechMenu(unitID)
	for i, cmdDesc in ipairs(menuCmdDescs) do
		InsertUnitCmdDesc(unitID, cmdDesc)
	end
	for i, cmdDesc in ipairs(CMD_DESCS_TO_ADD) do
		InsertUnitCmdDesc(unitID, cmdDesc)
	end
end

local lookup = {}

-- TODO: deal with all the copy-pasta from outpost_dropZone.lua menu by genericising it all into one horrifying 'bendSpringUIToMyWill.lua'
local function ShowMechMenu(unitID, unitDefID, menuType)
	currMenu[unitID] = menuType
	local cmdID = menuType and GG.CustomCommands.GetCmdID("CMD_MENU_" .. menuType:upper())
	for i, cmdDesc in ipairs(Spring.GetUnitCmdDescs(unitID)) do
		if cmdDesc.id == cmdID then -- show this menu as selected
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/selected.png',})
		elseif ignoredCmdDescs[cmdDesc.id] == 1 then -- show other menus as unselected
			EditUnitCmdDesc(unitID, i, {texture = 'bitmaps/ui/filter.png',})
		else -- show/hide other commands
			local hide = not lookup[unitDefID][menuType][cmdDesc.id]
			if menuType == "viewmods" then
				hide = not cmdDesc.action:find("mod")
			elseif menuType == "issueorder" and cmdDesc.id == mascCmdDesc.id then -- Kinda gross exception
				hide = not GG.mascUnits[unitID]
				Spring.Echo("Hey is that MASC?", hide)
			end
			EditUnitCmdDesc(unitID, i, {hidden = hide})
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if GG.mechCache[unitDefID] then
		-- first remove all the default command descriptions
		for i, cmd in pairs(CMDS_TO_REMOVE) do
			RemoveUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmd))
		end
		-- Add back in 
		AddMechMenu(unitID)
		GG.AddApps(unitID, unitDefID)
		
		if not lookup[unitDefID] then
			-- setup the cache
			lookup[unitDefID] = {}
			for i, menuType in pairs(menuStrings) do
				lookup[unitDefID][menuType] = {}
			end
			-- loop over all cmdDescs and assign to correct menu
			for i, cmdDesc in pairs(Spring.GetUnitCmdDescs(unitID)) do
				if cmdDesc.action:find("perk") then
					lookup[unitDefID]["pilotperks"][cmdDesc.id] = true
				elseif wantedCmdDescs[cmdDesc.id] then
					lookup[unitDefID]["issueorder"][cmdDesc.id] = true
				end
			end
			lookup[unitDefID]["issueorder"][jumpCmdDesc.id] = GG.jumpers[unitDefID]
			lookup[unitDefID]["issueorder"][mascCmdDesc.id] = false--true --GG.mascUnitDefs[unitDefID]
		end
		-- then show the order menu
		ShowMechMenu(unitID, unitDefID, "issueorder")
	end
end


function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if GG.mechCache[unitDefID] then
		if cmdID == CMD_WEAPON_TOGGLE then
			env = Spring.UnitScript.GetScriptEnv(unitID)
			Spring.UnitScript.CallAsUnit(unitID, env.ToggleWeapon, cmdParams[1]) -- 1st param is weaponNum
			return false
		elseif menuCmdIDs[cmdID] then
			ShowMechMenu(unitID, unitDefID, menuCmdIDs[cmdID])
			return false -- don't clear the command queue!
		elseif cmdID == CMD.ATTACK then
			local target = cmdParams[1]
			if ValidUnitID(target) then -- don't allow attack commands vs beacons et al
				return not GG.InvincibleUnit(GetUnitDefID(target))
			end
			return true
		end
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
