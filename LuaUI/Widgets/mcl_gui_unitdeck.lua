function widget:GetInfo()
	return {
		name      = "Unit Deck",
		desc      = "Displays mech units.",
		author    = "Smoth",
		date      = "Jan, 2014",
		license   = "PD",
		layer     = 5,
		enabled   = true  -- loaded by default?
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
local red = { 1.0, 0.1, 0.1, 1.0}

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
local maxLance = 1
local noUnit		= ":cl:bitmaps/ui/infocard/no_unit.png"

local testColors	= { {1,0,0,1}, {0,1,0,1}, {0,0,1,1},}
local lanceNames	= {"Alpha", "Bravo", "Charlie"}
--adding reverse lookup
for k,v in pairs(lanceNames)do
	lanceNames[v]=k
end

local lances = {}
for i = 1, 3 do
	lances[i] = {}
end
-- getting font in scale with screen

-------------------------------------------------------------------------------------
-- Initial gui setup
-------------------------------------------------------------------------------------
local function CreateWindows()	
	deckWindow = Chili.Window:New{
		parent	= Chili.Screen0;
		right	= "0%";
		y		= "75%";
		width	= "15%";
		height	= "25%";
		color	= clear;
		draggable	= false;
		dockable	= false;
		resizable	= false,
		padding 	= {0,0,0,0};
	}	
	
	setWindow = Chili.Window:New{
		parent	= deckWindow;
		right	= "0%";
		y		= "15%";
		width	= "100%";
		height	= "85%";
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
			--BorderTileImage 		= ":cl:panel2.png";
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
				height			= "15%";
				backgroundColor = maxLance >= counter and black or red;
				OnMouseUp = { 
					function()
						if counter > maxLance then return end 
						-- hide old tab
						setWindow:RemoveChild(deckSets[currentLance])
						local colour = maxLance >= currentLance and black or red
						updateButton(colour, grey)
						-- show new tab
						currentLance = counter
						spSendCommands("group" .. currentLance)
						Spring.SelectUnitArray(lances[currentLance])
						setWindow:AddChild(deckSets[currentLance])
						updateButton(green, white)
					end
				},
				OnDblClick = {
					function()
						spSendCommands("viewselection")
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
		-- set 2x2 grid for all units in this lance
		local unitNumber = 1
		for counterY = 0, 1 do -- 2 across
			for counterX = 0, 1 do	-- 2 down
				local hSpacing	= counterX*48+2
				local vSpacing	= counterY*48+2
				local myIndex	= unitNumber
				units[lanceNumber][unitNumber]	= Chili.Window:New{
					parent			= deckSets[lanceNumber];
					x				= hSpacing.."%";
					y				= vSpacing.."%";
					width			= 50 .."%";
					height			= 50 .."%";
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
							OnDblClick = {
								function()
									spSendCommands("viewselection")
									spSendCommands("track")
								end
							},
						},	
						Chili.Label:New{
							caption		= "-- Absent --";
							valign		= "top";
							y			= "20%";
							x			= "10%";
							fontsize	= fontSizes.medium;
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
							x			= "10%";
							y			= "10%";
							width		= "80%";
							height		= "80%";
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
local MY_TEAM = Spring.GetMyTeamID()
local MECH_DEFIDS = {}

local function CleanLance(unitID, lance)
	for slot = 1, 4 do
		if lances[lance][slot] == unitID then
			--Spring.Echo("CleanLance team:", Spring.GetMyTeamID(), "unit:", unitID, lance, "slot", slot)
			lances[lance][slot] = nil
		end
	end
end

local function SetLance(unitID, lanceNum)
	-- can't use insert as we may have missing indices
	local slot = 1
	while lances[lanceNum][slot] do
		slot = slot + 1
	end
	lances[lanceNum][slot] = unitID
	--Spring.Echo("SetLance team:", Spring.GetMyTeamID(), "unit:", unitID, lanceNum, "slot", slot)
	-- clean other lances
	for lance = 1, 3 do
		if lance ~= lanceNum then
			CleanLance(unitID, lance)
			return
		end
	end
end

local function SetMaxLance(newMaxLance)
	maxLance = newMaxLance
	local cache = currentLance
	for lance = 1,3 do
		currentLance = lance
		local colour = maxLance >= currentLance and black or red
		updateButton(colour, grey)
	end
	currentLance = cache
	updateButton(green, white)
end

function widget:Initialize()
	MY_TEAM = Spring.GetMyTeamID()
	for unitDefID, ud in pairs(UnitDefs) do
		if ud.customParams.baseclass == "mech" then
			MECH_DEFIDS[unitDefID] = true
		end
	end
	WG.MECH_DEFIDS = MECH_DEFIDS -- make available to other widgets
		
	widgetHandler:RegisterGlobal('SetLance', SetLance)
	widgetHandler:RegisterGlobal('CleanLance', CleanLance)
	widgetHandler:RegisterGlobal('SetMaxLance', SetMaxLance)
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
	local groupUnits = lances[currentLance] -- spGetGroupUnits(currentLance)
	for unitNumber = 1, 4 do
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
		if unitNumber <  5 then
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
			local unitDefId		= spGetUnitDefID(unitId)
			local currentDef 	= UnitDefs[unitDefId]
			if unitDefId and currentDef then
				Spring.Echo("you have more than the lance supports in group #" .. currentLance, unitNumber, currentDef.name)
			end
		end
	end	
end

-------------------------------------------------------------------------------------
-- update
-------------------------------------------------------------------------------------
function widget:Update()
	updateLance()
end

function widget:PlayerChanged()
	local teamID = Spring.GetMyTeamID()
	if teamID ~= MY_TEAM then
		MY_TEAM = teamID
		-- proceed to rebuild the deck
		local allTheUnits = Spring.GetTeamUnitsSorted(teamID)
		local mechsToLance = {}
		for unitDefID, unitTable in pairs(allTheUnits) do
			if unitDefID and MECH_DEFIDS[unitDefID] then
				for _, unitID in pairs(unitTable) do
					mechsToLance[unitID] = true
				end
			end
		end
		-- first delete all existing lances
		for i = 1, 3 do
			lances[i] = {}
		end
		-- then rebuild using the rules params
		for mechID in pairs(mechsToLance) do
			SetLance(mechID, spGetUnitRulesParam(mechID, "LANCE"))
		end
		maxLance = Spring.GetTeamRulesParam(teamID, "LANCES")
		SetMaxLance(maxLance)
	end
end