function widget:GetInfo()
	return {
		name		= "MC:L - Dropship Menu",
		desc		= "Always accessible dropship menu!",
		author		= "Anarchid",
		date		= "In year 2014",
		license     = "GNU GPL v2",
		layer		= math.huge,
		enabled   	= false,
		handler		= true,
	}
end

-- TODO: localize spring calls, other silly optimizations

local activeOrder = {};

local orderCbills = 0;
local orderTonnage = 0;
local orderPopulation = 0;

local orderClassQuantity = {};

local unitButtons = {};
local classButtons = {};
local submitButton = nil;
local leftColumn = nil;
local rightColumn = nil;

local buildableUnits = {};
local activeClass = nil;

local buttonColor = {nil, nil, nil, 1}
local buttonColorFac = {0.6, 0.6, 0.6, 0.3}
local buttonColorWarning = {1, 0.2, 0.1, 1}
local buttonColorDisabled = {0.2,0.2,0.2,1}
local imageColorDisabled = {0.3, 0.3, 0.3, 1}

local orderColorNormal =  {1, 1, 1, 1};
local orderColorEmpty =   {0.2, 0.2, 0.2, 1};
local orderColorTransit = {1, 0.9, 0, 1};
local orderColorArrived = {1, 0.9, 0.2, 1};
local orderColorInvalid = {1, 0.1, 0, 1};

local floor 			= math.floor;
local format			= string.format;
local emptyTable = {};
local GetTeamRulesParam = Spring.GetTeamRulesParam;

local myDropZoneUnitDefID;

local classHasEnabled = {};

local CMD_SEND_ORDER = Spring.GetGameRulesParam("CMD_SEND_ORDER");

local typeStringAliases = { -- whitespace is to try and equalise resulting font size
	["lightmech"] 	= "Light     \nMechs", 
	["mediummech"] 	= "Medium  \nMechs", 
	["heavymech"] 	= "Heavy    \nMechs", 
	["assaultmech"] = "Assault  \nMechs", 
	["vehicle"] 	= "Vehicles ", 
	["vtol"] 		= "VTOL     ",
	["aero"]		= "Aero     ",
}

local myTeamID = nil;

--- helper functions

local function FramesToMinutesAndSeconds(frames)
	local gameSecs = floor(frames / 30)
	local minutes = format("%02d",  floor(gameSecs / 60))
	local seconds = format("%02d", gameSecs % 60)
	return minutes, seconds
end

function CreateClassButton(class)
	local color = {0,0,0,1}
	local button = Chili.Button:New {
		name = "btnClass_"..class,
		parent = leftColumn,
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		minWidth = 40,
		minHeight = 40,
		caption = typeStringAliases[class],
		isDisabled = false,
		unitClass = class,
		OnClick = {ClassClick},
	}
	
	local label = Chili.Label:New{
		bottom=10,
		right = 10,
		height = 10,
		name = "lblClass_"..class,
		parent = button,
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		caption = "",
		visible = false,
		backgroundColor = buttonColor,
		color = {1,0,0,1}
	}
	
	button.label = label;
	classButtons[class] = button;
end

function CreateUnitButton(unitDefID, className)
	local texture = "#"..unitDefID;
	
	local cCost = UnitDefs[unitDefID].metalCost;
	local tCost = UnitDefs[unitDefID].energyCost;

	
	local button = Chili.Button:New {
		name = "btnOrder_"..UnitDefs[unitDefID].name,
		parent = rightColumn,
		padding = {10, 10, 10, 10},
		margin = {0, 0, 0, 0},
		minWidth = 96,
		minHeight = 96,
		width = "100%",
		--height = "100%",
		caption = "",
		isDisabled = false,
		unitDefID = unitDefID,
		unitClass = className,
		tCost = tCost,
		cCost = cCost,
		visible = false,
		OnClick = {UnitClick},
	}
	
	image = Chili.Image:New {
		y=0,
		x=0,
		bottom=0,
		right=0,
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		keepAspect = true, --false,	--isState;
		file = texture,
		parent = button,
		opacity = 0.5,
	}
	
	label = Chili.Label:New{
		bottom = 10,
		right = 0,
		height = 0,
		name = "lblOrder_"..UnitDefs[unitDefID].name,
		parent = image,
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		caption = "",
		visible = false,
		backgroundColor = buttonColor,
	}
	
	button.label = label;
	button.image = image;
	
	button:Hide();
	
	table.insert(unitButtons[className], button);
end

function CreateUnitButtons(class)
	local classUnits = buildableUnits[class];

	for i, unitDefID in pairs(classUnits) do
		CreateUnitButton(unitDefID, class);
	end
end

function ShowUnitButtons(class)
	local buttons = {};
	if not (activeClass == nil) then
		buttons = unitButtons[activeClass];
		for i, button in pairs(buttons) do
			rightColumn:HideChild(button);
		end
	end
	
	activeClass = class;
	
	buttons = unitButtons[class];
	for i, button in pairs(buttons) do
		rightColumn:ShowChild(button);
	end
	
end

function UpdateUI()
	if (Spring.GetSpectatingState()) then
		--widgetHandler:RemoveWidget()
		return
	end
		local cBills = floor(Spring.GetTeamResources(myTeamID, "metal"));
		local tonnage = floor(Spring.GetTeamResources(myTeamID,"energy"));
		local coolDownFrame = tonumber(GetTeamRulesParam(myTeamID, "DROPSHIP_COOLDOWN") or 0);
		local population = tonumber(GetTeamRulesParam(myTeamID, "TEAM_SLOTS_REMAINING") or 0);
		
		local availableTonnage = tonnage - orderTonnage;
		local availableCbills = cBills - orderCbills;
		local availablePopulation = population - orderPopulation;
		
		local currentFrame = Spring.GetGameFrame();
		
		local myDropzone = GetDropZoneID();
		
		if myDropzone == nil then
				submitButton.font.color = orderColorEmpty;
				submitButton.backgroundColor = buttonColorDisabled;
				submitButton.isDisabled = false;
				submitButton:SetCaption('No Dropzone');			
		else
			if coolDownFrame >= 0 then -- dropship is either in orbit or in transit
				local frames = math.max(coolDownFrame - currentFrame, 0);
				minutes, seconds = FramesToMinutesAndSeconds(frames);
				
				if (frames <= 0) then
					if availableCbills >= 0 then
						if orderPopulation > 0 then
							submitButton.font.color = orderColorNormal;
							submitButton.backgroundColor = buttonColor;
							submitButton.isDisabled = false;
							submitButton:SetCaption('Send Order');
						else
							submitButton.font.color = orderColorEmpty;
							submitButton.backgroundColor = buttonColorDisabled;
							submitButton.isDisabled = false;
							submitButton:SetCaption('Order Empty');
						end
					else
						submitButton.font.color = orderColorInvalid;
						submitButton.backgroundColor = buttonColorDisabled;
						submitButton.isDisabled = true;
						submitButton:SetCaption('Not Enough\n C-Bills');			
					end
				else
					submitButton.font.color = orderColorTransit;
					submitButton.backgroundColor = buttonColorDisabled;
					submitButton:SetCaption('Dropship\nIn Transit');
					submitButton.isDisabled = true;		
				end
			else -- dropship is currently ingame
				submitButton.font.color = orderColorTransit;
				submitButton.backgroundColor = buttonColorDisabled;
				submitButton:SetCaption('Dropship\n Arrived');
				submitButton.isDisabled = true;
			end
		end
		
		for class, buttons in pairs(unitButtons) do
			classHasEnabled[class] = false;
			for i,button in ipairs(buttons) do
				local cCost = button.cCost;
				local tCost = button.tCost;
				local name = UnitDefs[button.unitDefID].name
				
				if cCost <= availableCbills and tCost <= availableTonnage then
					classHasEnabled[class] = true;
					button.isDisabled = false;
					button.image.color = {1,1,1,1};
					button.backgroundColor = buttonColor;
				else
					button.isDisabled = true;
					button.backgroundColor = buttonColorDisabled;
					button.image.color = {0.3, 0.3, 0.3, 0.7}
				end
			end
		end
		
		for class, button in pairs(classButtons) do
			if classHasEnabled[class] then
				button.backgroundColor = buttonColor;
			else
				button.backgroundColor = buttonColorDisabled;
			end
		end	
end

function ResetOrder()
	activeOrder = {};
	orderCbills = 0;
	orderTonnage = 0;
	orderPopulation = 0;
	orderClassQuantity = {};
	
	for class, buttons in pairs(unitButtons) do
		classButtons[class].label:SetCaption('');
		for i,button in ipairs(buttons) do
			button.label:SetCaption('');
		end
	end
	
	UpdateUI();
end

function GetDropZoneID()
	local myDropzones = Spring.GetTeamUnitsByDefs(myTeamID, myDropZoneUnitDefID);
	return myDropzones[1];
end

-- EVENT HANDLERS 
function ClassClick(chiliButton, x, y, button, mods) 
	local class = chiliButton.unitClass;
	ShowUnitButtons(class);
end

function UnitClick(chiliButton, x, y, button, mods) 
	local udID = chiliButton.unitDefID;
	local unitClass = chiliButton.unitClass;
	local cCost = chiliButton.cCost;
	local tCost = chiliButton.tCost;
	
	local quantity = activeOrder[udID] or 0;
	local classQuantity = orderClassQuantity[unitClass] or 0;
	
	if button == 1 and not chiliButton.isDisabled then
		orderCbills = orderCbills + cCost;
		orderTonnage = orderTonnage + tCost;
		orderPopulation = orderPopulation + 1;
		quantity = quantity + 1;
		classQuantity = classQuantity + 1;
	elseif button == 3 and quantity > 0 then
		orderCbills = orderCbills - cCost;
		orderTonnage = orderTonnage - tCost;
		orderPopulation = orderPopulation - 1;
		quantity = quantity - 1;
		classQuantity = classQuantity - 1;
	end
	
	activeOrder[udID] = quantity;
	orderClassQuantity[unitClass] = classQuantity;
	
	if(quantity > 0) then
		chiliButton.label:SetCaption(quantity);
	else
		chiliButton.label:SetCaption('');
	end
	
	if(classQuantity > 0) then
		classButtons[unitClass].label:SetCaption(classQuantity);
	else
		classButtons[unitClass].label:SetCaption('');
	end
	
	UpdateUI();
end

function OrderClick(chiliButton, x, y, button, mods) 
	if (chiliButton.isDisabled) then return end;
	local myDropzone = GetDropZoneID();
	
	if myDropzone == nil then
		UpdateUI();
		return;
	end
	
	for udID, quantity in pairs (activeOrder) do
		for i=1,quantity do
			Spring.GiveOrderToUnit(myDropzone, -udID, emptyTable, emptyTable);
		end
	end
	
	Spring.GiveOrderToUnit(myDropzone, CMD_SEND_ORDER, emptyTable, emptyTable);

	ResetOrder();	
end


function widget:GameFrame(n)
	if n % 32 == 0 then
		UpdateUI();
	end
end

function widget:Initialize()
	if (Spring.GetSpectatingState()) then
		--widgetHandler:RemoveWidget()
		return
	end
	
	if (not WG.Chili) then
		widgetHandler:RemoveWidget()
		return
	end
	
	myTeamID = Spring.GetLocalTeamID();
	mySide = Spring.GetTeamInfo(myTeamID);
	mySidePrefix = Spring.GetTeamRulesParam(myTeamID, "side"); 

	local myDropZoneUnitName = mySidePrefix..'_dropzone';
	Spring.Echo(myDropZoneUnitName);
	
	myDropZoneUnitDefID = UnitDefNames[myDropZoneUnitName].id;
	Spring.Echo(tostring(myDropZoneUnitDefID));
	
	for unitDefID, unitDef in pairs(UnitDefs) do
		local unitType = unitDef.customParams.baseclass;
		local name = unitDef.name;
		if unitType == "mech" then -- or unitType == "vehicle" then
			if name:sub(1, 2) == mySidePrefix then
				local name = unitDef.name
				local cp = unitDef.customParams
				local basicType = cp.baseclass
				
				local class = "special";
				
				if basicType == "mech" then
					-- sort into light, medium, heavy, assault
					local mass = unitDef.mass
					local light = mass < 40 * 100
					local medium = not light and mass < 60 * 100
					local heavy = not light and not medium and mass < 80 * 100
					local assault = not light and not medium and not heavy
					local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
					class = weight .. "mech"
				else
					class = basicType
				end
				
				if buildableUnits[class] == nil then buildableUnits[class] = {} end
				table.insert(buildableUnits[class], unitDefID);
			end
		end
	end
	
	Chili = WG.Chili
	local screen0 = Chili.Screen0
	
	submitButton = Chili.Button:New {
		name = "btnSubmit",
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		minHeight = 40,
		x = 0,
		y = 0,
		width = "100%",
		caption = "SEND ORDER",
		isDisabled = false,
		tCost = tCost,
		cCost = cCost,
		visible = false,
		OnClick = {OrderClick},
	}
		
	leftColumn = Chili.StackPanel:New{
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		orientation = vertical,
		x = 0,
		y = 40,
		bottom = 0,
		right = '50%',
		draggable = false,
		resizable = false,
		selectable = false,
	}
	
	rightColumn = Chili.LayoutPanel:New{
		padding = {0, 0, 0, 0},
		margin = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		centerItems = false,
		orientation = vertical,
		x = "50%",
		y = 40,
		right = 0,
		bottom = 0,
		draggable = false,
		resizable = false,
		selectable = false,
	}
	
	window0 = Chili.Window:New{
		x = '0%',
		y = '15%',
		dockable = true,
		parent = screen0,
		caption = "",
		draggable = true,
		dockable = true,
		resizable = true,
		dragUseGrip = true,
		clientWidth = 150,
		clientHeight = 400,
		backgroundColor = {0,0,0,1},
		skinName  = "DarkGlass",		
		children = {submitButton,leftColumn,rightColumn},
	}
	
	for class, units in pairs (buildableUnits) do
		unitButtons[class] = {};
		CreateClassButton(class);
		CreateUnitButtons(class);
	end
	
	UpdateUI();
	
end

