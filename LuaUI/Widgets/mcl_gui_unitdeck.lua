function widget:GetInfo()
	return {
		name      = "Unit Deck",
		desc      = "Displays mech units.",
		author    = "Smoth",
		date      = "Jan, 2014",
		license   = "PD",
		layer     = 5,
		enabled   = false  -- loaded by default?
	}
end

--spring stuffs
local spGetSelectedUnits	= Spring.GetSelectedUnits 
local spGetUnitDefID		= Spring.GetUnitDefID
local spGetUnitRulesParam	= Spring.GetUnitRulesParam
local spGetUnitHealth		= Spring.GetUnitHealth
local spGetGroupUnits		= Spring.GetGroupUnits
local spSendCommands		= Spring.SendCommands

local green	= { 0.0, 1.0, 0.0, 1.0}
local white	= { 1.0, 1.0, 1.0, 1.0}
local grey	= { 0.4, 0.4, 0.4, 1.0}
local darkGrey	= { 0.2, 0.2, 0.2, 1.0}
local black = { 0.0, 0.0, 0.0, 1.0}
local clear = { 0.0, 0.0, 0.0, 0.0}
local olive = { 0.25, 0.3, 0.1, 1.0}

-- windows
local deckWindow
-- child windows
local cardSection

-- TODO: until we get scaling of font size within elements this will have to do
local vsx,vsy = gl.GetViewSizes()

local fontSizes	={	large	= vsx/87.27272727272727,
					medium	= vsx/160,
					small	= vsx/240,}
					
-- unit buttons
local units	= {}
local unitIdCache	= {}
local deckSets		= {}
local deckButtons	= {}

local currentLance  = 1
local noUnit		= ":cl:bitmaps/ui/infocard/no_unit.png"

local testColors	= { {1,0,0,1}, {0,1,0,1}, {0,0,1,1},}
local lanceNames	= {"Alpha", "Bravo", "Charlie"}
--adding reverse lookup
for k,v in pairs(lanceNames)do
	lanceNames[v]=k
end
-- getting font in scale with screen

-------------------------------------------------------------------------------------
-- Initial gui setup
-------------------------------------------------------------------------------------
local function CreateWindows()	
	deckWindow = Chili.Window:New{
		parent	= Chili.Screen0;
		right	= "0%";
		y		= "60%";
		width	= "15%";
		height	= "40%";
		color	= clear;
		draggable	= false;
		dockable	= false;
		resizable	= false,
		padding 	= {0,5,0,0};
	}	
	
	setWindow = Chili.Window:New{
		parent	= deckWindow;
		right	= "0%";
		y		= "10%";
		width	= "100%";
		height	= "90%";
		color		= grey;
		draggable	= false;
		dockable	= false;
		resizable	= false;
		padding 	= {0,0,0,0};
	}

end

-------------------------------------------------------------------------------------
-- helper funtion made to update colors of lance tabs on click
-------------------------------------------------------------------------------------
local function updateButton(backGroundColor, textColor)
	deckButtons[currentLance].backgroundColor	= backGroundColor
	deckButtons[currentLance].font.color		= textColor
	deckButtons[currentLance]:Invalidate()
end

-------------------------------------------------------------------------------------
-- builds out each lance tab and unit in each lance, done to reduce redudant work
-------------------------------------------------------------------------------------
local function initializeSetView()
	for counter = 1, 3 do
		deckSets[counter]	= Chili.ScrollPanel:New{
			name		= "lance list #" .. counter;
			BorderTileImage 		= ":cl:panel2.png";
			padding 	= {0,0,0,0};
			width		= "100%";  
			height		= "100%"; 
			dockable	= false;
			draggable	= false;
			resizable	= false;
			backgroundColor = grey;
		}	
	end

	for counter = 1, 3 do
		local spacing = (counter-1) * 34
		deckButtons[counter]	= Chili.Button:New{	
				tiles 			= {10, 10, 10, 10};
				parent			= deckWindow;	
				name			= "lance #" .. counter;
				caption			= lanceNames[counter];
				fontsize		= fontSizes.large;
				fontShadow		= false;
				font			= {	outline			= true;
									outlineWidth	= 5;};
				textColor 		= grey;
				x				= spacing .. "%";
				width			= "32%";
				height			= "11%";
				backgroundColor = black;
				OnMouseUp = { 
					function()
						-- hide old tab
						setWindow:RemoveChild(deckSets[currentLance])
						updateButton(black, grey)
						-- show new tab
						currentLance = counter
						spSendCommands("group" .. currentLance)
						setWindow:AddChild(deckSets[currentLance])
						updateButton(green, white)
					end
				},
			}	

	end
	
	setWindow:AddChild(deckSets[currentLance])
	updateButton(green, white)
	
	-- adds all lance units to their respective lances.
	for lanceNumber = 1, 3 do
		-- initialize lance groups
		units[lanceNumber]	= {}
		unitIdCache[lanceNumber]	= {}
		-- set 2x4 grid for all units in this lance
		local unitNumber = 1
		for counterY = 0, 3 do -- 4 across
			for counterX = 1, 2 do	-- 2 down
				local hSpacing	= (counterX-1)*48+2
				local vSpacing	= (counterY)*24+2
				local myIndex	= unitNumber
				units[lanceNumber][unitNumber]	= Chili.Window:New{
					parent			= deckSets[lanceNumber];
					x				= hSpacing.."%";
					y				= vSpacing.."%";
					width			= 50 .."%";
					height			= 25 .."%";
					draggable		= false;
					dockable		= false;
					resizable		= false;					
					color 			= clear;
					padding         = {0, 0, 0, 0};
					children		= {
						Chili.Button:New{		
							caption		= "";
							fontsize	= fontSizes.medium;
							x			= 0;
							y			= 0;
							width		= "100%";
							height		= "100%";
							backgroundColor		= clear;
							OnMouseUp = { 					
								function()					
									WG.currentUnitId = unitIdCache[lanceNumber][myIndex]
									spSendCommands("selectunits clear +" .. WG.currentUnitId)
								end
							},
						},	
						Chili.Label:New{
							caption		= "-- Absent --";
							valign		= "top";
							y			= "20%";
							x			= "10%";
							fontsize	= fontSizes.large;
						},				
						Chili.Progressbar:New{
							color			= green;
							backgroundColor	= black;
							font			= {	outline			= true;										
												outlineWidth	= 6; };
							fontsize		= fontSizes.medium;
							x				= "5%";
							height			= "20%";
							width			= "90%";
						},
						Chili.Image:New{
							file 		= noUnit;
							x			= "25%";
							y			= "10%";
							width		= "50%";
							height		= "90%";
							keepAspect	= true;
							color		= grey;
						}						
					},					
				}
				unitNumber = unitNumber +1
			end -- end lance units column add
		end -- end lance units row add
	end -- end lance units count
end

-------------------------------------------------------------------------------------
-- Init
-------------------------------------------------------------------------------------
function widget:Initialize()
	Chili = WG.Chili
	
	if (not Chili) then
		widgetHandler:RemoveWidget()
		return
	end

	
	CreateWindows()
	initializeSetView()
end	


-------------------------------------------------------------------------------------
-- function updates lance preview of units and switches currently displayed lance set
-------------------------------------------------------------------------------------
local function updateLance()
	local groupUnits = spGetGroupUnits(currentLance)
	for unitNumber = 1, 8 do
		local unitPreview = units[currentLance][unitNumber].children
		--Spring.Echo("removed", currentLance, unitNumber)
		deckSets[currentLance]:RemoveChild(units[currentLance][unitNumber])
		
		-- if you want the preview back good for testing.
		-- unitPreview[2]:SetCaption("-- Absent --")
		-- unitPreview[3].color 	= darkGrey
		-- unitPreview[3]:SetValue(100)
		-- unitPreview[3]:SetCaption("")
		-- unitPreview[4].file		= noUnit
		-- unitPreview[4].color	= darkGrey 
		-- unitPreview[4]:Invalidate()
		
		unitIdCache[currentLance][unitNumber] = nil
	end
	
	-- update all the units in the lance, ensure they have some health
	for unitNumber,unitId in pairs(groupUnits)do
		if unitNumber <  9 then
			local unitDefId		= spGetUnitDefID(unitId)
			local currentDef 	= UnitDefs[unitDefId]
			local health, maxHealth	= spGetUnitHealth(unitId)
			local unitPreview = units[currentLance][unitNumber].children
			
			unitIdCache[currentLance][unitNumber] = unitId
			
			-- if you want the preview back good for testing.
			--Spring.Echo(currentLance,unitNumber)
			--Spring.Echo(units[currentLance][unitNumber])
			--unitPreview[3].color = green
			if currentDef then
				deckSets[currentLance]:AddChild(units[currentLance][unitNumber])
				unitPreview[2]:SetCaption(currentDef.humanName)			
				unitPreview[3]:SetValue(health/maxHealth*100)
				unitPreview[3]:SetCaption(math.floor(maxHealth - (maxHealth - health)))--math.floor(maxHealth - health))

				unitPreview[4].file		= '#' .. unitDefId
				unitPreview[4].color	= white
				unitPreview[4]:Invalidate()
			else -- just a catch all for some reason this was happening after a unit was dead/removed causing the script to blowup
				deckSets[currentLance]:RemoveChild(units[currentLance][unitNumber])
				--Spring.Echo("removed def".. unitDefId .. "from lance " .. currentLance)
			end
		else
			Spring.Echo("you have more than the lance supports in group #" .. currentLance)
		end
	end	
end

-------------------------------------------------------------------------------------
-- update
-------------------------------------------------------------------------------------
function widget:Update()
	updateLance()
end