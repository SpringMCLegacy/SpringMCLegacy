function widget:GetInfo()
	return {
		name      = "Unit Card",
		desc      = "Displays unit information.",
		author    = "Smoth + zvero + ChatGPT",
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
local spGiveOrderToUnit		= Spring.GiveOrderToUnit
local spGetUnitWeaponState	= Spring.GetUnitWeaponState
local spGetGameFrame		= Spring.GetGameFrame
local spGetFrameTimeOffset	= Spring.GetFrameTimeOffset

local green	= { 0.0, 1.0, 0.0, 1.0}
local darkGreen	= { 0.0, 0.7, 0.0, 1.0}
local white	= { 1.0, 1.0, 1.0, 1.0}
local grey	= { 0.4, 0.4, 0.4, 1.0}
local red	= { 1.0, 0.0, 0.0, 1.0}
local black = { 0.0, 0.0, 0.0, 1.0}
local clear = { 0.0, 0.0, 0.0, 0.0}
local olive = { 0.25, 0.3, 0.1, 1.0}

-- reload colors modulate the existing Chili button skin
local weaponSkinTints = {
	active = {
		empty = {0.34, 0.34, 0.34, 1.00},
		fill  = darkGreen,
	},
	disabled = {
		empty = {0.04, 0.04, 0.04, 1.00},
		fill  = {0.00, 0.32, 0.00, 1.00},
	},
	destroyed = {
		empty = red,
		fill  = red,
	},
}

local GameConstants = VFS.Include("gamedata/GameConstants.lua", nil, VFS.ZIP)
local ammoTypesInclude = GameConstants.ammoTypes
local ammoTypes = {}
for ammoType, _ in pairs(ammoTypesInclude) do
	ammoTypes[ammoType:lower()] = "ammo_" .. ammoType:lower()
end

local jumpJetsColor	= { 0.3, 0.5, 1.0, 1.0}
local HPColor		= { 0.0, 0.5, 1.0, 1.0}
local XPColor		= white
-- done so we are not frequently building a new table for colors
local chestColorTable		= green
local colortable			= green
local heatColorTable		= clear

-- TODO: until we get scaling of font size within elements this will have to do
local vsx,vsy = gl.GetViewSizes()
local fontSizes	={	large	= vsx/87.27272727272727,
					medium	= vsx/160,
					small	= vsx/240,}
--chili stuffs
local Chili

-- windows
local mechCardWindow
-- child windows
local mechWindow
local mechWeaponsWindow
local mechStatsWindow
local mechAmmoWindow
local mechCardName
local mechHeat
local mechOverHeat
local testbutton

-- current mech
local currentUnitDefId
local currentUnitId
local lastUnitId

-- list for mech parts. Used to determine what parts are
-- displayed in card and what the image is named
local GameConstants = VFS.Include("gamedata/GameConstants.lua", nil, VFS.ZIP)
local partsList	= GameConstants.partsList

local currentPartsList	= {}

local partsParamList	= {	arm_left	= "limb_hp_left_arm",
							arm_right	= "limb_hp_right_arm",
							leg_left	= "limb_hp_left_leg",
							leg_right	= "limb_hp_right_leg",
							turret		= "limb_hp_turret",
							rotor		= "limb_hp_rotor",
							left_wing	= "limb_hp_lwing",
							right_wing	= "limb_hp_rwing",}

-- weapon lists for side bar
local weaponButton		= {}
local CMD_WEAPON_TOGGLE = Spring.GetGameRulesParam("CMD_WEAPON_TOGGLE")

-- parts for display
local parts = {}
for part in pairs(partsList) do
	parts[part] = {}
end

-- temporary storage for part list
local currentParts	= {}

-- ammo details for display
local ammoTotals		= {}

-- stores all known ammo types for this mech
local ammoNameCache		= {}

local dangerZONE	= false
local phase			= 0

local maxWeaponCount = 32;
local GAME_SPEED = (Game and Game.gameSpeed) or 30

-- because concatination creates strings in mem that can flood the garbage collector
-- we are going to use this lookuptable to mittigate the string building
local weapon_Lookup	= {}

for i=1,maxWeaponCount do
	weapon_Lookup[i] = "weapon_" .. i
end

-- look up for status setting
local weaponStatus	=	{	active = darkGreen,
							disabled = black,
							destroyed = red,}
-------------------------------------------------------------------------------------
-- Function to read string into table
-------------------------------------------------------------------------------------
local function StringToTable(input)
   return loadstring("return " .. (input or "{}"))()
end

-------------------------------------------------------------------------------------
-- Reload helpers
-------------------------------------------------------------------------------------
local function Clamp01(value)
	if value <= 0 then
		return 0
	elseif value >= 1 then
		return 1
	end
	return value
end

local function SafeGetUnitWeaponState(unitID, weaponNum, stateName)
	if not spGetUnitWeaponState then
		return nil
	end

	local ok, value = pcall(spGetUnitWeaponState, unitID, weaponNum, stateName)
	if ok and type(value) == "number" then
		return value
	end

	return nil
end

-- Return the best live estimate of the complete reload cycle in simulation
-- frames. Current Recoil exposes reloadTimeXP as the weapon reload time after
-- the owning unit's reload-speed/experience modifier, in seconds. reloadTime
-- and the static WeaponDef value are retained only as compatibility fallbacks.
local function GetWeaponReloadDurationFrames(unitID, weaponNum, weaponDefID, remainingFrames)
	local candidates = {}

	local reloadTimeXP = SafeGetUnitWeaponState(unitID, weaponNum, "reloadTimeXP")
	if reloadTimeXP and reloadTimeXP > 0 then
		candidates[#candidates + 1] = reloadTimeXP * GAME_SPEED
	end

	local legacyReloadTime = SafeGetUnitWeaponState(unitID, weaponNum, "reloadTime")
	if legacyReloadTime and legacyReloadTime > 0 then
		candidates[#candidates + 1] = legacyReloadTime * GAME_SPEED
	end

	local weaponDef = weaponDefID and WeaponDefs[weaponDefID]
	if weaponDef then
		local staticReload = weaponDef.reloadTime or weaponDef.reloadtime or weaponDef.reload
		if type(staticReload) == "number" and staticReload > 0 then
			candidates[#candidates + 1] = staticReload * GAME_SPEED
		end
	end

	-- A full reload duration cannot be shorter than the amount of reload still
	-- remaining. This also rejects a value if an older engine exposes a field
	-- with different semantics than current Recoil documentation.
	for i = 1, #candidates do
		local frames = candidates[i]
		if frames >= remainingFrames - 1 then
			return math.max(frames, remainingFrames)
		end
	end

	-- Last-resort fallback. This means a weapon first selected midway through a
	-- reload begins at 0%, but still reaches 100% exactly at reloadFrame. On
	-- current Recoil builds the live duration fields above should be available.
	return math.max(remainingFrames, 1)
end

local function GetCurrentFrameTime()
	local gameFrame = spGetGameFrame and spGetGameFrame() or 0

	-- Interpolate between simulation frames when the engine provides a render
	-- offset. Reload readiness itself remains anchored to reloadFrame.
	if spGetFrameTimeOffset then
		local ok, offset = pcall(spGetFrameTimeOffset)
		if ok and type(offset) == "number" then
			gameFrame = gameFrame + offset
		end
	end

	return gameFrame
end

local function GetWeaponReloadProgress(unitID, weaponNum, weaponDefID, gameFrame)
	local reloadFrame = SafeGetUnitWeaponState(unitID, weaponNum, "reloadFrame")

	if not reloadFrame or reloadFrame <= gameFrame then
		return 1
	end

	local remainingFrames = reloadFrame - gameFrame
	local durationFrames = GetWeaponReloadDurationFrames(
		unitID,
		weaponNum,
		weaponDefID,
		remainingFrames
	)

	if not durationFrames or durationFrames <= 0 then
		return 1
	end

	return Clamp01(1 - (remainingFrames / durationFrames))
end

local function CopyColor(color, fallback)
	color = color or fallback or white
	return {
		color[1] or 1,
		color[2] or 1,
		color[3] or 1,
		color[4] == nil and 1 or color[4],
	}
end

local function MixColor(a, b, amount)
	amount = Clamp01(amount or 0)
	local inverse = 1 - amount
	return {
		(a[1] or 0) * inverse + (b[1] or 0) * amount,
		(a[2] or 0) * inverse + (b[2] or 0) * amount,
		(a[3] or 0) * inverse + (b[3] or 0) * amount,
		(a[4] == nil and 1 or a[4]) * inverse + (b[4] == nil and 1 or b[4]) * amount,
	}
end

local function GetWeaponSkinTints(button)
	local status = button.weaponStatus or "disabled"
	local palette = weaponSkinTints[status] or weaponSkinTints.disabled

	if status == "destroyed" then
		return palette.empty, palette.fill
	end

	local hovered = button.state and button.state.hovered
	if not hovered then
		return palette.empty, palette.fill
	end

	-- Use the actual skin's own focus color for hover. Keep the unloaded bed
	-- darker so the reload fraction remains readable while the row is hovered.
	local focus = button.stockFocusColor or button.focusColor or {1.0, 0.7, 0.1, 0.8}
	local emptyMix = (status == "active") and 0.42 or 0.30
	local emptyTint = MixColor(palette.empty, focus, emptyMix)
	local fillTint = CopyColor(focus)

	return emptyTint, fillTint
end

local function ScaleColor(color, factor)
	color = color or white
	factor = factor or 1
	return {
		(color[1] or 0) * factor,
		(color[2] or 0) * factor,
		(color[3] or 0) * factor,
		(color[4] == nil and 1 or color[4]) * factor,
	}
end

-- Emits one textured rectangle as a triangle strip. Keeping this callback
-- outside the draw loop avoids allocating a closure for every one of the nine
-- skin slices on every Chili redraw.
local function EmitTexturedQuad(x0, y0, x1, y1, u0, v0, u1, v1)
	gl.MultiTexCoord(0, u0, v0)
	gl.Vertex(x0, y0)
	gl.MultiTexCoord(0, u0, v1)
	gl.Vertex(x0, y1)
	gl.MultiTexCoord(0, u1, v0)
	gl.Vertex(x1, y0)
	gl.MultiTexCoord(0, u1, v1)
	gl.Vertex(x1, y1)
end

-- Draw the resolved Chili skin texture as a normal nine-slice, optionally
-- revealing only the left-most fraction. Clipping happens entirely in the
-- button's LOCAL geometry: any slice crossed by the reload boundary has
-- both its destination X and corresponding U coordinate shortened together.
-- This preserves the original image proportions and works whether Chili is
-- drawing directly to screen or into an RTT/FBO.
local function DrawClippedNineSlice(image, tiles, width, height, tint, clipFraction)
	if not image or not gl.Texture or not gl.TextureInfo then
		return false
	end

	width = tonumber(width) or 0
	height = tonumber(height) or 0
	if width <= 0 or height <= 0 then
		return false
	end

	gl.Texture(0, image)
	local texInfo = gl.TextureInfo(image)
	if not texInfo or not texInfo.xsize or not texInfo.ysize or texInfo.xsize <= 0 or texInfo.ysize <= 0 then
		gl.Texture(0, false)
		return false
	end

	local sourceLeft   = (tiles and tiles[1]) or 0
	local sourceTop    = (tiles and tiles[2]) or 0
	local sourceRight  = (tiles and tiles[3]) or 0
	local sourceBottom = (tiles and tiles[4]) or 0

	local destLeft   = sourceLeft
	local destTop    = sourceTop
	local destRight  = sourceRight
	local destBottom = sourceBottom

	-- Match Chili's _DrawTiledTexture behavior when a control is smaller than
	-- the sum of its fixed edge slices. UVs stay based on the ORIGINAL source
	-- slices while only the destination edge sizes are scaled down.
	local horizontalEdges = sourceLeft + sourceRight
	local verticalEdges = sourceTop + sourceBottom
	local scaleX = horizontalEdges > 0 and (width / horizontalEdges) or 1
	local scaleY = verticalEdges > 0 and (height / verticalEdges) or 1
	local scale = math.min(scaleX, scaleY)
	if scale < 1 then
		destLeft   = destLeft * scale
		destTop    = destTop * scale
		destRight  = destRight * scale
		destBottom = destBottom * scale
	end

	local texWidth = texInfo.xsize
	local texHeight = texInfo.ysize

	local xs = {0, destLeft, width - destRight, width}
	local ys = {0, destTop, height - destBottom, height}
	local us = {0, sourceLeft / texWidth, 1 - sourceRight / texWidth, 1}
	local vs = {0, sourceTop / texHeight, 1 - sourceBottom / texHeight, 1}

	local clipX = width
	if clipFraction ~= nil then
		clipX = width * Clamp01(clipFraction)
		if clipX <= 0 then
			gl.Texture(0, false)
			return true
		end
	end

	gl.Color(tint or white)

	for row = 1, 3 do
		local y0 = ys[row]
		local y1 = ys[row + 1]
		local v0 = vs[row]
		local v1 = vs[row + 1]

		for column = 1, 3 do
			local x0 = xs[column]
			local x1 = xs[column + 1]
			local u0 = us[column]
			local u1 = us[column + 1]

			if x0 < clipX and x1 > x0 and y1 > y0 then
				if x1 > clipX then
					local fraction = (clipX - x0) / (x1 - x0)
					x1 = clipX
					u1 = u0 + ((u1 - u0) * fraction)
				end

				if x1 > x0 then
					gl.BeginEnd(
						GL.TRIANGLE_STRIP,
						EmitTexturedQuad,
						x0, y0, x1, y1,
						u0, v0, u1, v1
					)
				end
			end
		end
	end

	gl.Texture(0, false)
	return true
end

-- Only used as a defensive fallback for an unusual skin without the expected
-- TileImageBK/FG fields. No clipping is attempted through this path.
local function DrawFallbackStockWeaponSkin(button, tint)
	local drawStock = button.stockDrawControl
	if not drawStock then
		gl.Color(tint or white)
		gl.Rect(0, 0, button.width or 0, button.height or 0)
		return
	end

	local oldCaption = button.caption
	local oldBackgroundColor = button.backgroundColor
	local oldBorderColor = button.borderColor
	local oldBorderColor2 = button.borderColor2
	local oldFocusColor = button.focusColor
	local oldHovered = button.state and button.state.hovered

	if button.state then
		button.state.hovered = false
	end

	button.caption = ""
	button.backgroundColor = tint
	button.borderColor = button.stockBorderColor or oldBorderColor
	button.borderColor2 = button.stockBorderColor2 or oldBorderColor2
	button.focusColor = button.stockFocusColor or oldFocusColor
	drawStock(button)

	button.caption = oldCaption
	button.backgroundColor = oldBackgroundColor
	button.borderColor = oldBorderColor
	button.borderColor2 = oldBorderColor2
	button.focusColor = oldFocusColor
	if button.state then
		button.state.hovered = oldHovered
	end
end

local function DrawWeaponButton(button)
	local progress = Clamp01(button.reloadProgress or 1)
	local emptyTint, fillTint = GetWeaponSkinTints(button)
	local pressed = button.state and button.state.pressed

	if pressed then
		emptyTint = ScaleColor(emptyTint, 0.4)
		fillTint = ScaleColor(fillTint, 0.4)
	end

	local width = button.width or 0
	local height = button.height or 0
	local tiles = button.tiles
	local backgroundImage = button.TileImageBK
	local foregroundImage = button.TileImageFG

	-- Full unloaded bed using the exact stock background artwork.
	local drewBackground = DrawClippedNineSlice(
		backgroundImage,
		tiles,
		width,
		height,
		emptyTint,
		nil
	)

	if not drewBackground then
		DrawFallbackStockWeaponSkin(button, emptyTint)
	end

	-- Loaded portion: same full-size nine-slice, locally clipped at the reload
	-- boundary. At progress=1 this simply covers the entire bed with the ready
	-- tint; at progress=0 no fill is visible.
	if progress > 0 then
		local drewFill = DrawClippedNineSlice(
			backgroundImage,
			tiles,
			width,
			height,
			fillTint,
			progress
		)

		if not drewFill then
			gl.Color(fillTint)
			gl.Rect(0, 0, width * progress, height)
		end
	end

	-- Draw the stock foreground once over both reload regions. Normal Robocracy
	-- buttons use a transparent FG tint until hovered; hover therefore becomes a
	-- coherent yellow outline/highlight without erasing the progress split.
	local foregroundTint = button.stockBorderColor or button.borderColor or clear
	if button.state and button.state.hovered then
		foregroundTint = button.stockFocusColor or button.focusColor or {1.0, 0.7, 0.1, 0.8}
	elseif pressed then
		foregroundTint = ScaleColor(foregroundTint, 0.4)
	end

	if foregroundImage then
		DrawClippedNineSlice(
			foregroundImage,
			tiles,
			width,
			height,
			foregroundTint,
			nil
		)
	end

	-- Caption is drawn once, above the skin layers.
	if button.caption and button.caption ~= "" then
		button.font:Print(
			button.caption,
			width * 0.5,
			height * 0.5,
			"center",
			"center"
		)
	end
end

local function UpdateWeaponReloadVisual(unitID, weaponNum, weaponUnitDef, gameFrame)
	if weaponNum > maxWeaponCount then
		return
	end

	local button = weaponButton[weaponNum - 1]
	if not button then
		return
	end

	local status = spGetUnitRulesParam(unitID, weapon_Lookup[weaponNum])
	if status ~= "active" and status ~= "disabled" and status ~= "destroyed" then
		status = "disabled"
	end

	local progress
	if status == "destroyed" then
		-- A destroyed weapon has no tactically meaningful reload state.
		progress = 1
	else
		local weaponDefID = weaponUnitDef and weaponUnitDef.weaponDef
		progress = GetWeaponReloadProgress(unitID, weaponNum, weaponDefID, gameFrame)
	end

	-- Avoid needless redraws for ready weapons. Reloading weapons still update
	-- continuously because GetCurrentFrameTime() includes render interpolation.
	if button.weaponStatus ~= status or button.reloadProgress ~= progress then
		button.weaponStatus = status
		button.reloadProgress = progress
		button:Invalidate()
	end
end

-------------------------------------------------------------------------------------
-- Sets damage values on parts display
-------------------------------------------------------------------------------------
local function MechPartStatus(chestColorTable)
	-- get part damage
	for partId, partName in pairs(currentPartsList)do
		-- check to ensure this part has been paired with a param
		if partsParamList[partName] then
			local partHealth 	= spGetUnitRulesParam(currentUnitId, partsParamList[partName]) or 100
			colortable	= {((100 - partHealth)/100), (partHealth/100), 0 ,1}
			--Spring.Echo(partName,partHealth)
			-- part destroyed
			if partHealth <1 then
				colortable = black
			end
			currentParts[partId].color =	colortable
			currentParts[partId]:Invalidate()
		else
			currentParts[partId].color =	chestColorTable
			currentParts[partId]:Invalidate()
		end
	end
end

-------------------------------------------------------------------------------------
-- constrols strobing effect used by the heat warning
-------------------------------------------------------------------------------------
local function HeatPulse()
	phase = phase + 0.2
	if dangerZONE == true then -- LANA! LAAAAAAAAAANA!
		local pulseValue = .5+.5*math.sin(phase)
		local inversePulseValue = .5*math.sin(phase/2)
		--Spring.Echo(inversePulseValue)
		mechOverHeat.color		= {pulseValue, 0,  0, 1};
		mechOverHeat:Invalidate()
		mechOverHeat.children[1].font.color	= {(inversePulseValue)+0.5,(0.5*inversePulseValue)+0.5,0,1};
		mechOverHeat.children[1]:SetCaption("DANGER")
		mechOverHeat.children[1]:Invalidate()
	else
		mechOverHeat.color	= clear;
		mechOverHeat:Invalidate()
		mechOverHeat.children[1]:SetCaption("")
		mechOverHeat.children[1]:Invalidate()
	end
end

local function ToggleWeapon(unitDefID, weaponNum, button)
	if spGetUnitRulesParam(currentUnitId, weapon_Lookup[weaponNum]) ~= "destroyed" then
		spGiveOrderToUnit(currentUnitId, CMD_WEAPON_TOGGLE, {weaponNum}, {})
		-- weapon status is authoritative on the synced side; Update() will read it
		if button then
			button:Invalidate()
		end
	end
end

-------------------------------------------------------------------------------------
-- Initializes unit stats at start
-------------------------------------------------------------------------------------
local function FillCardStats()
	if currentUnitId and spGetUnitDefID(currentUnitId) then
		local health, maxHealth	= spGetUnitHealth(currentUnitId)
		local currentDef		= UnitDefs[currentUnitDefId]
		local weapons			= currentDef.weapons
		if currentDef.customParams.sectorangle then
			weapons[#weapons] = nil -- remove special 'Sight' weapon
		end
		colortable				= green

		-- Spring.Echo(currentUnitDefId, UnitDefs[currentUnitDefId].humanName)
		mechCardName:SetCaption(UnitDefs[currentUnitDefId].humanName)

		--clear all weapons
		for counter = 0, maxWeaponCount-1 do
			mechWeaponsWindow:RemoveChild(weaponButton[counter])
		end

		--get weapon status
		local lastWeaponId
		local gameFrame = GetCurrentFrameTime()
		for weaponNum, weaponUnitDef in pairs(weapons) do
			--Spring.Echo( WeaponDefs[weaponUnitDef.weaponDef].description)
			local currentWeapon		= weaponButton[weaponNum-1]

			currentWeapon:SetCaption(WeaponDefs[weaponUnitDef.weaponDef].description)
			currentWeapon.OnClick = {	function(self)
											ToggleWeapon(currentDef, weaponNum, self)
										end }
			mechWeaponsWindow:AddChild(weaponButton[weaponNum-1])
			UpdateWeaponReloadVisual(currentUnitId, weaponNum, weaponUnitDef, gameFrame)

			lastWeaponId = weaponNum
		end

		-- set hp bar and chest damage
		-- Spring.Echo(health/maxHealth,health,maxHealth)
		chestColorTable	= {((maxHealth - health)/maxHealth), (health/maxHealth), 0 ,1}

		MechPartStatus(chestColorTable)
		mechStatsWindow.children[2]:SetValue(spGetUnitRulesParam(currentUnitId, "jump_reload_bar") or 0)
		mechStatsWindow.children[3]:SetValue(spGetUnitRulesParam(currentUnitId, "perk_xp")  or 0)

		-- hiding extra ammo windows
		for counter = 1, 4 do
			mechAmmoWindow:RemoveChild(ammoTotals[counter])
		end

		-- show only what we have, if we have ammo
		if ammoNameCache[currentUnitDefId] then
			for k,v in pairs(ammoNameCache[currentUnitDefId])do
				mechAmmoWindow:AddChild(ammoTotals[k])
				mechAmmoWindow.children[k]:SetCaption(v)
				if ammoTypes[v] then
					mechAmmoWindow.children[k]:SetValue(spGetUnitRulesParam(currentUnitId, ammoTypes[v])  or "0")
				else
					mechAmmoWindow.children[k]:SetValue("0")
					Spring.Echo("ammo type:", v, "is new, please edit the table ammoTypes in mcl_gui_unitcard.lua")
				end
			end
		end

		local heat = spGetUnitRulesParam(currentUnitId, "heat") or 0
		local excessHeat = spGetUnitRulesParam(currentUnitId, "excess_heat") or 0

		--Spring.Echo(spGetUnitRulesParam(currentUnitId, "heat") or 0)
		if (spGetUnitRulesParam(currentUnitId, "excess_heat") or 0) > 50 then
			dangerZONE = true
		else
			dangerZONE = false
		end

		HeatPulse()

		if heat >10 then
			heatColorTable	= { heat/100, 0, 0, 1}
			--Spring.Echo(heatColorTable[1], heatColorTable[2], heatColorTable[3], heatColorTable[4])
		else
			heatColorTable	= clear
		end

		--Spring.Echo(heat)
		mechStatsWindow.children[1].color	= heatColorTable
		mechStatsWindow.children[1]:SetValue(heat)
		mechStatsWindow.children[1].children[1]:SetValue(excessHeat)
		if heat > 50 then
			mechHeat.color			= heatColorTable;
			mechHeat:Invalidate()
		else
			mechHeat.color			= clear;
			mechHeat:Invalidate()
		end
	end
end

-------------------------------------------------------------------------------------
-- creates initial ui elements
-------------------------------------------------------------------------------------
local function CreateWindows()
	mechCardWindow = Chili.Window:New{
		--parent	= Chili.Screen0;
		name	= "mech card";
		right	= "0%";
		y		= "40%";
		width	= "15%";
		height	= "35%";
		draggable	= false;
		resizable	= false;
		color		= grey;
		padding		= {8,8,8,8};
	}

	mechCardName = Chili.Label:New{
		parent	= mechCardWindow;
		caption	= "No Mech Selected";
		valign	= "top";
		x		= "5%";
		fontsize	= fontSizes.large;
		minWidth	= 0;
		minHeight	= 0;
	}

	mechWindow = Chili.Window:New{
		parent	= mechCardWindow;
		x		= "0%";
		y		= "10%";
		width	= "50%";
		height	= "50%";
		color		= grey;
		draggable	= false;
		resizable	= false;
		padding		= {0,0,0,0};
	}

	mechHeat = Chili.Window:New{
		parent	= mechWindow;
		TileImage	= ":cl:bitmaps/ui/infocard/screen.png";
		width		= "100%";
		height		= "100%";
		color		= heatColorTable;
		draggable	= false;
		resizable	= false;
	}

	mechOverHeat = Chili.Image:New{
		file		= ":cl:bitmaps/ui/infocard/warning_bar.png";
		parent		= mechHeat;
		y			= "30%";
		width		= "100%";
		height		= "30%";
		color		= clear;
		draggable	= false;
		resizable	= false;
		keepAspect	= false;
		children	= {
			Chili.Label:New{
				caption		= "";
				y			= "10%";
				fontsize	= fontSizes.large;
				minWidth	= 0;
				minHeight	= 0;
			}
		};
	}

	mechWeaponsWindow = Chili.Window:New{
		parent	= mechCardWindow;
		name	= "mech weapons list";
		right	= "0%";
		y		= "10%";
		width	= "49%";
		height	= "90%";
		color		= grey;
		draggable	= false;
		resizable	= false;
		padding		= {8,8,8,8};
	}

	mechStatsWindow = Chili.Window:New{
		parent	= mechCardWindow;
		x		= "0%";
		y		= "60%";
		width	= "49%";
		height	= "19%";
		color		= grey;
		draggable	= false;
		resizable	= false;
		padding		= {8,8,8,8};
		children = {
			Chili.Progressbar:New{
				name			= "Mech heat";
				color			= HPColor;
				backgroundColor	= black;
				y				= "00%";
				x				= "15%";
				height			= "30%";
				width			= "85%";
				padding			= {0,0,0,6};
				children = {
					Chili.Progressbar:New{
					name			= "Mech excess health";
					TileImageFG		= ":cl:bitmaps/ui/infocard/tech_progressbar_danger.png";
					color			= { 1.0, 1.0, 1.0, 0.8};
					backgroundColor	= clear;
					height			= "20%";
					width			= "100%";
					min				= 0;
					}
				}
			},
			Chili.Progressbar:New{
				name			= "Mech Jumpjet Fuel";
				color			= jumpJetsColor;
				backgroundColor	= black;
				y				= "35%";
				x				= "15%";
				height			= "30%";
				width			= "85%";
			},
			Chili.Progressbar:New{
				name			= "Mech Perk XP";
				color			= XPColor;
				backgroundColor	= black;
				y				= "70%";
				x				= "15%";
				height			= "30%";
				width			= "85%";
			},
			Chili.Label:New{
				caption	= "H";
				y		= "0%";
				x		= "0%";
				fontsize = fontSizes.medium;
			},
			Chili.Label:New{
				caption	= "J";
				y		= "35%";
				x		= "0%";
				fontsize = fontSizes.medium;
			},
			Chili.Label:New{
				caption	= "XP";
				y		= "60%";
				x		= "0%";
				fontsize = fontSizes.medium;
			},
		}
	}

	mechAmmoWindow = Chili.Window:New{
		parent	= mechCardWindow;
		x		= "0%";
		y		= "80%";
		width	= "49%";
		height	= "19%";
		color		= grey;
		draggable	= false;
		resizable	= false;
		padding		= {8,8,8,8};
	}

end

-------------------------------------------------------------------------------------
-- builds out extra elements so the code is not bloated
-------------------------------------------------------------------------------------
local function FillOutWindows()
	-- builds out weapon list
	for counter = 0 ,maxWeaponCount-1 do
		local currentLevel = (counter)*10
		local button = 	Chili.Button:New{
				name				= "mech weapon #" .. counter;
				caption				= '-- OFFLINE --';
				fontsize			= fontSizes.medium;
				font				= {	outline			= true;
										outlineWidth	= 2;};
				x					= "0%";
				y					= currentLevel .. "%";
				width				= "100%";
				height				= "12%";
				padding				= {0,0,0,0};
				backgroundColor 	= grey;
				OnClick = { function(self)
					ToggleWeapon(counter)
					--Spring.SendLuaRulesMsg ( cmd )
				end }, -- ToggleWeapon(counter)
			}

		button.stockDrawControl = button.DrawControl
		button.stockBorderColor = CopyColor(button.borderColor, clear)
		button.stockBorderColor2 = CopyColor(button.borderColor2, clear)
		button.stockFocusColor = CopyColor(button.focusColor, {1.0, 0.7, 0.1, 0.8})
		button.weaponStatus = "disabled"
		button.reloadProgress = 1
		button.DrawControl = DrawWeaponButton
		weaponButton[counter] = button
	end

	--builds out unit images
	for partType,_	in pairs(partsList)do
		-- for each type, as in mech, unit etc
		for partNumber, partName in pairs(partsList[partType])do
			parts[partType][partNumber] = Chili.Image:New{
				file 		= ":cl:bitmaps/ui/infocard/"..partType.."/dummy_"..partName..".png";
				x			= "5%";
				y			= "5%";
				height		= "90%";
				width		= "90%";
				keepAspect	= false;
				color		= black;}
		end
	end

	-- ammo counters
	for counter = 1, 4 do
		local yPosition = (counter - 1) *25
		ammoTotals[counter] = Chili.Progressbar:New{
				caption			= "Ammo";
				name			= "ammo progressbar #" .. counter;
				fontSize		= fontSizes.medium;
				color			= grey;
				font			= {	outline			= true;
									outlineWidth	= 5;};
				backgroundColor	= black;
				y				= yPosition .. "%";
				height			= "25%";
				width			= "100%";
			}
	end
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
	local tempAmmoTable	= {}
	for unitDefId, unitDef in pairs(UnitDefs)do
		if unitDef.customParams and unitDef.customParams.maxammo then
			tempAmmoTable[unitDefId] =	StringToTable(unitDef.customParams.maxammo)
			--Spring.Echo(unitDefId,tempAmmoTable[unitDefId])
		end
	end

	for unitDefId,_ in pairs(UnitDefs)do
		local counter = 1
		--not all units may have ammo ratings
		if tempAmmoTable[unitDefId] then
			ammoNameCache[unitDefId] = {}
			for k,v in pairs(tempAmmoTable[unitDefId])do
				ammoNameCache[unitDefId][counter] = k
				counter = counter+1
			end
		end
	end

	CreateWindows()
	FillOutWindows()
end

-------------------------------------------------------------------------------------
-- update
-------------------------------------------------------------------------------------
function widget:Update(s)
	local health, maxHealth

	--if we have anything selected
	local currentUnits = spGetSelectedUnits()
	--if we have only 1 unit selected
	if #currentUnits == 1 then
		WG.currentUnitId = currentUnits[1]
	end

	--start flozi needs to add a proper sendtounsynced but for now..
	if currentUnitId and spGetUnitDefID(currentUnitId) then
		local weapons		= UnitDefs[spGetUnitDefID(currentUnitId)].weapons
		local gameFrame = GetCurrentFrameTime()

		for weaponNum, weaponUnitDef in pairs(weapons) do
			if weaponNum <= maxWeaponCount then
				UpdateWeaponReloadVisual(currentUnitId, weaponNum, weaponUnitDef, gameFrame)
			end
		end
	end
	--end flozi needs to add a proper sendtounsynced but for now..

	--only once, only on unit change
	if WG.currentUnitId ~= lastUnitId then
		--dangerZONE = false

		lastUnitId			= WG.currentUnitId
		currentUnitId		= WG.currentUnitId
		currentUnitDefId	= spGetUnitDefID(currentUnitId)
		local unitType		= UnitDefs[currentUnitDefId].customParams.baseclass
		local unitDef		= UnitDefs[currentUnitDefId]


		if unitType then
			Chili.Screen0:RemoveChild(mechCardWindow)
			Chili.Screen0:AddChild(mechCardWindow)
			-- TODO: FIND A MORE ELEGANT SOLUTON!
			-- rips out all possible unit images
			for partType,_	in pairs(partsList)do
				-- for each type, as in mech, unit etc
				for partNumber, partName in pairs(partsList[partType])do
					mechWindow:RemoveChild(parts[partType][partNumber])
				end
			end

			-- changes image set based on type.
			if partsList[unitType]then
				currentParts			= parts[unitType]
				currentPartsList		= partsList[unitType]
				-- builds out mech image
				for partNumber, partName in pairs(currentPartsList)do
					mechWindow:AddChild(currentParts[partNumber])
				end
			else
				--Spring.Echo("it appears we have encountered an uncovered unitType", unitType)
				-- TODO: Mute this for now
			end

			FillCardStats()
		--else
			--Spring.Echo(UnitDefs[currentUnitDefId].customParams.baseclass)
		end
	-- not a new unit lets update it's stats.
	else
		if currentUnitId and spGetUnitDefID(currentUnitId) then
			health, maxHealth	= spGetUnitHealth(currentUnitId)
			if maxHealth and health > 0 then
				chestColorTable	= {((maxHealth - health)/maxHealth), (health/maxHealth), 0 ,1}

				MechPartStatus(chestColorTable)
				mechStatsWindow.children[2]:SetValue(spGetUnitRulesParam(currentUnitId, "jump_reload_bar") or 0)
				mechStatsWindow.children[3]:SetValue(spGetUnitRulesParam(currentUnitId, "perk_xp") or 0)

				-- update ammo display when units have ammo
				if ammoNameCache[currentUnitDefId] then
					for k,v in pairs(ammoNameCache[currentUnitDefId])do
						if ammoTypes[v] then
							mechAmmoWindow.children[k]:SetValue(spGetUnitRulesParam(currentUnitId, ammoTypes[v])  or 0)
						else
							mechAmmoWindow.children[k]:SetValue(0)
							Spring.Echo("ammo type:", v, "is new, please edit the table ammoTypes in mcl_gui_unitcard.lua")
						end
					end
				end


				local heat			= spGetUnitRulesParam(currentUnitId, "heat") or 0
				local excessHeat	= spGetUnitRulesParam(currentUnitId, "excess_heat") or 0

				if heat >10 then
					heatColorTable	= { heat/100, (100-heat)/100, 0, 1}
					--Spring.Echo(heatColorTable[1], heatColorTable[2], heatColorTable[3], heatColorTable[4])
				else
					heatColorTable	= clear
				end

				--Spring.Echo(excessHeat)
				if ( excessHeat > 50 ) then
					dangerZONE = true
					--heatColorTable	= red
					HeatPulse()
				else
					dangerZONE = false
					HeatPulse()
				end

				--Spring.Echo(heat)
				mechStatsWindow.children[1].color	= heatColorTable
				mechStatsWindow.children[1]:SetValue(heat)
				mechStatsWindow.children[1].children[1]:SetValue(excessHeat)
				if heat > 50 then
					mechHeat.color			= heatColorTable;
					mechHeat:Invalidate()
				else
					mechHeat.color			= clear;
					mechHeat:Invalidate()
				end
			else
				Chili.Screen0:RemoveChild(mechCardWindow)
			end
		end
	end
end
