function widget:GetInfo()
	return {
		name		= "MC:L - Unit Orders",
		desc		= "ChiliUi window that contains all the commands a unit has",
		author		= "Sunspot",
		date		= "2011-06-15",
		license     = "GNU GPL v2",
		layer		= math.huge,
		enabled   	= false,
		handler		= true,
	}
end
-- INCLUDES
VFS.Include("LuaRules/Includes/utilities.lua")

-- CONSTANTS
local MAXBUTTONSONROW = 3
local COMMANDSTOEXCLUDE = {
	"timewait",
	"deathwait",
	"squadwait",
	"gatherwait",
	"loadonto",
	"nextmenu",
	"prevmenu", 
	"submit_order",
	"menu",
	"label"
}

local Chili

-- MEMBERS
local x
local y
local imageDir = 'LuaUI/Images/commands/'
local commandWindow
local stateCommandWindow
local buildCommandWindow
local updateRequired = true

-- CONTROLS
local spGetActiveCommand 	= Spring.GetActiveCommand
local spGetActiveCmdDesc 	= Spring.GetActiveCmdDesc
local spGetSelectedUnits    = Spring.GetSelectedUnits
local spSendCommands        = Spring.SendCommands


-- SCRIPT FUNCTIONS
function LayoutHandler(xIcons, yIcons, cmdCount, commands)
	widgetHandler.commands   = commands
	widgetHandler.commands.n = cmdCount
	widgetHandler:CommandsChanged()
	local reParamsCmds = {}
	local customCmds = {}

	return "", xIcons, yIcons, {}, customCmds, {}, {}, {}, {}, reParamsCmds, {[1337]=9001}
end

function ClickFunc(chiliButton, x, y, button, mods) 
	local index = Spring.GetCmdDescIndex(chiliButton.cmdid)
	if (index) then
		local left, right = (button == 1), (button == 3)
		local alt, ctrl, meta, shift = mods.alt, mods.ctrl, mods.meta, mods.shift

		if DEBUG then Spring.Echo("active command set to ", chiliButton.cmdid) end
		Spring.SetActiveCommand(index, button, left, right, alt, ctrl, meta, shift)
	end
end

-- Returns the caption, parent container and commandtype of the button	
function findButtonData(cmd)
	local isState = (cmd.type == CMDTYPE.ICON_MODE and #cmd.params > 1)
	local isBuild = (cmd.id < 0)	
	local buttontext = ""
	local container
	local texture = nil
	if not isState and not isBuild then
		buttontext = cmd.name
		container = commandWindow
	elseif isState then
		local indexChoice = cmd.params[1] + 2
		buttontext = cmd.params[indexChoice]
		container = stateCommandWindow
	else
		container = buildCommandWindow
		texture = '#'..-cmd.id
	end
	return buttontext, container, isState, isBuild, texture	
end

function createMyButton(cmd)
	if(type(cmd) == 'table')then
		buttontext, container, isState, isBuild, texture = findButtonData(cmd)

		local color = {0,0,0,1}
		local button = Chili.Button:New {
			parent = container,
			padding = {5, 5, 5, 5},
			margin = {0, 0, 0, 0},
			minWidth = 40,
			minHeight = 40,
			maxWidth = 120,
			maxHeight = 40,
			caption = buttontext,
			isDisabled = false,
			cmdid = cmd.id,
			OnMouseDown = {ClickFunc},
		}
		
		if texture then
			if DEBUG then Spring.Echo("texture",texture) end
			image= Chili.Image:New {
				x=0;
				y=0;
				right=0;
				bottom=0;
				keepAspect = true,	--isState;
				file = texture;
				parent = button;
			}		
		end
	end
end

local startsWith = function(self, piece)
  return string.sub(self, 1, string.len(piece)) == piece
end

function filterUnwanted(commands)
	local uniqueList = {}
	if DEBUG then Spring.Echo("Total commands ", #commands) end
	if not(#commands == 0) then
		j = 1
		for _, cmd in ipairs(commands) do
			if DEBUG then Spring.Echo("Adding command ", cmd.action) end
			
			if not table.contains(COMMANDSTOEXCLUDE,cmd.action) then
				if (cmd.id < 0) then
					if UnitDefs[-cmd.id].isImmobile then
						uniqueList[j] = cmd
						j = j + 1
					end
				else
					uniqueList[j] = cmd
					j = j + 1
				end
			end
		end
	end
	return uniqueList
end

function resetWindow(container)
	container:ClearChildren()
	container.xstep = 1
	container.ystep = 1
end

function loadPanel()
	resetWindow(commandWindow)
	resetWindow(stateCommandWindow)
	resetWindow(buildCommandWindow)
	local commands = Spring.GetActiveCmdDescs()
	commands = filterUnwanted(commands)
	table.sort(commands,function(x,y) return x.action < y.action end)
	for cmdid, cmd in pairs(commands) do
		rowcount = createMyButton(commands[cmdid]) 
	end
end

-- WIDGET CODE
function widget:Initialize()
	widgetHandler:ConfigLayoutHandler(LayoutHandler)
	Spring.ForceLayoutUpdate()
	spSendCommands({"tooltip 0"})
	
	if (not WG.Chili) then
		widgetHandler:RemoveWidget()
		return
	end

	Chili = WG.Chili
	local screen0 = Chili.Screen0
		
	commandWindow = Chili.Grid:New{
		x = 0,
		y = 0,
		right = '50%',
		bottom = 0,
		draggable = false,
		resizable = false,
		dragUseGrip = false,		
		children = {},
	}

	stateCommandWindow = Chili.Grid:New{
		x = '75%',
		y = 0,
		right = 0,
		bottom = 0,
		draggable = false,
		resizable = false,
		dragUseGrip = false,		
		children = {},
	}	

	buildCommandWindow = Chili.Grid:New{
		x = '50%',
		y = 0,
		width = "25%",
		height = "100%",
		draggable = false,
		resizable = false,
		dragUseGrip = false,		
		children = {},
	}		
	
	window0 = Chili.Window:New{
		x = '50%',
		y = '15%',	
		dockable = true,
		parent = screen0,
		caption = "",
		draggable = true,
		resizable = true,
		dragUseGrip = true,
		clientWidth = 400,
		clientHeight = 200,
		backgroundColor = {0,0,0,1},
		skinName  = "DarkGlass",		
		children = {commandWindow,stateCommandWindow,buildCommandWindow},
	}
	
end

function widget:CommandsChanged()
	if DEBUG then Spring.Echo("commandChanged called") end
	updateRequired = true
end

function widget:DrawScreen()
    if updateRequired then
        updateRequired = false
		loadPanel()
    end
end

function widget:Shutdown()
  widgetHandler:ConfigLayoutHandler(nil)
  Spring.ForceLayoutUpdate()
  spSendCommands({"tooltip 1"})
end
