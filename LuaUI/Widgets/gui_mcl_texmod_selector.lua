--------------------------------------------------------------------------------
-- MCL radial start-of-match paint-scheme selector
-- Author: zvero + ChatGPT
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name = "MCL Paint Scheme Selector",
		desc = "Radial faction paint-scheme selector for match setup",
		author = "zvero + ChatGPT",
		date = "2026-09-04",
		license = "GNU GPL, v2 or later",
		layer = 1000,
		enabled = true,
	}
end

local TEXMOD = VFS.Include("LuaRules/Configs/mcl_texmods.lua", nil, VFS.ZIP)
local sideData = TEXMOD.LoadSideData()
local texmodData = TEXMOD.LoadTexmodData()
local MSG_PREFIX = "MCLTEXMOD|"
local DEBUG_MSG_PREFIX = "MCLTEXMODALL|"

--------------------------------------------------------------------------------
-- Tuning
--------------------------------------------------------------------------------

local SIDE_POLL_INTERVAL = 0.10
local SIDE_STABLE_DELAY = 0.45
local PENDING_TIMEOUT = 1.25
local INITIAL_GRACE = 0.35
local SELECTION_TIMEOUT = 15.0

local PREVIEW_DIR = "bitmaps/ui/texmods/"
local BASE_INNER_RADIUS = 82
local BASE_OUTER_RADIUS = 250
local BASE_PREVIEW_RADIUS = 158
local BASE_PREVIEW_SIZE = 64
local BASE_TEXT_RADIUS = 218
local BASE_TITLE_OFFSET = 310
local BASE_STATUS_OFFSET = 287
local BASE_CENTER_RADIUS = 65
local WEDGE_GAP_RADIANS = math.rad(2.0)
local WEDGE_SEGMENTS = 14

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local myTeamID
local effectiveSide = ""
local effectiveSideEntry
local effectiveSideSource = "none"
local allowedTexmods = {TEXMOD.DEFAULT_TEXMOD}
local previewPaths = {}
local missingPreviewLogged = {}
local observedStartUnit
local stableElapsed = 0
local elapsed = 0
local selectionElapsed = 0
local pollAccumulator = 0
local menuVisible = false
local completed = false
local pendingSelection
local pendingElapsed = 0
local hoveredIndex
local currentSelection = TEXMOD.DEFAULT_TEXMOD
local debugAll = false
local vsx, vsy = 1, 1
local scale = 1
local centerX, centerY = 0, 0
local innerRadius, outerRadius, previewRadius, previewSize, textRadius, centerRadius = 0, 0, 0, 0, 0, 0
local titleOffset, statusOffset = 0, 0

local sin = math.sin
local cos = math.cos
local atan2 = math.atan2
local sqrt = math.sqrt
local pi = math.pi
local twoPi = pi * 2
local floor = math.floor
local ceil = math.ceil
local max = math.max
local min = math.min

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function PrettyName(name)
	if name == TEXMOD.DEFAULT_TEXMOD then
		return "TEAM"
	end
	return TEXMOD.GetTexmodDisplayName(name, texmodData)
end

local function CanonicalSideCaption()
	if debugAll then
		return "SELECT PAINT SCHEME  -  DEBUG: ALL TEXMODS"
	end
	if effectiveSide == "" then
		return "SELECT PAINT SCHEME"
	end
	return "SELECT PAINT SCHEME  -  " .. tostring(effectiveSide)
end

local function RefreshGeometry()
	vsx, vsy = Spring.GetViewGeometry()
	scale = max(0.72, min(1.45, vsy / 1080))
	centerX = vsx * 0.5
	centerY = vsy * 0.5
	innerRadius = BASE_INNER_RADIUS * scale
	outerRadius = BASE_OUTER_RADIUS * scale
	previewRadius = BASE_PREVIEW_RADIUS * scale
	previewSize = BASE_PREVIEW_SIZE * scale
	textRadius = BASE_TEXT_RADIUS * scale
	centerRadius = BASE_CENTER_RADIUS * scale
	titleOffset = BASE_TITLE_OFFSET * scale
	statusOffset = BASE_STATUS_OFFSET * scale
end

local function BuildPreviewCache()
	previewPaths = {}
	for i = 1, #allowedTexmods do
		local texmod = allowedTexmods[i]
		local path = PREVIEW_DIR .. texmod .. ".png"
		if VFS.FileExists(path) then
			previewPaths[texmod] = path
		elseif texmod ~= TEXMOD.DEFAULT_TEXMOD and not missingPreviewLogged[texmod] then
			missingPreviewLogged[texmod] = true
			Spring.Echo("[MCL TexMods] No preview image for '" .. tostring(texmod) .. "' at " .. path .. "; using text-only radial entry.")
		end
	end
end

local function FindHoveredIndex(mx, my)
	if not menuVisible or #allowedTexmods == 0 then
		return nil
	end
	local dx = mx - centerX
	local dy = my - centerY
	local dist = sqrt(dx * dx + dy * dy)
	if dist < innerRadius or dist > outerRadius then
		return nil
	end

	local count = #allowedTexmods
	local sector = twoPi / count
	local start = (pi * 0.5) - (sector * 0.5)
	local angle = atan2(dy, dx)
	while angle < start do angle = angle + twoPi end
	while angle >= start + twoPi do angle = angle - twoPi end
	local index = floor((angle - start) / sector) + 1
	if index < 1 then index = 1 end
	if index > count then index = count end
	return index
end

local function RefreshSelectionState()
	local value = Spring.GetTeamRulesParam(myTeamID, TEXMOD.TEAM_RULE_PARAM)
	currentSelection = TEXMOD.NormalizeTexmod(value)
end

local function RefreshEffectiveSide(force)
	local startUnit = Spring.GetTeamRulesParam(myTeamID, TEXMOD.START_UNIT_RULE_PARAM)
	local side, sideEntry, source = TEXMOD.GetEffectiveTeamSide(myTeamID, sideData)

	local changed = force
		or startUnit ~= observedStartUnit
		or side ~= effectiveSide
		or sideEntry ~= effectiveSideEntry

	if not changed then
		return false
	end

	observedStartUnit = startUnit
	effectiveSide = side or ""
	effectiveSideEntry = sideEntry
	effectiveSideSource = source or "none"
	allowedTexmods = debugAll and TEXMOD.GetAllTexmods(texmodData) or TEXMOD.GetAllowedTexmods(effectiveSide, texmodData, effectiveSideEntry)
	BuildPreviewCache()
	stableElapsed = 0
	selectionElapsed = 0
	menuVisible = false
	pendingSelection = nil
	pendingElapsed = 0
	RefreshSelectionState()

	Spring.Echo(string.format(
		"[MCL TexMods] Paint selector resolved faction '%s' via %s; %d paint option(s).",
		tostring(effectiveSide), tostring(effectiveSideSource), #allowedTexmods
	))
	return true
end

local function FinishSelector()
	completed = true
	menuVisible = false
	hoveredIndex = nil
	pendingSelection = nil
	pendingElapsed = 0
	selectionElapsed = 0
end

local function SelectTexmod(texmod)
	texmod = TEXMOD.NormalizeTexmod(texmod)
	pendingSelection = texmod
	pendingElapsed = 0
	Spring.SendLuaRulesMsg((debugAll and DEBUG_MSG_PREFIX or MSG_PREFIX) .. texmod)

	-- Team is initialized before the selector appears, so this is already
	-- authoritative even if no rules-param transition is observable.
	if texmod == TEXMOD.DEFAULT_TEXMOD
		and TEXMOD.NormalizeTexmod(Spring.GetTeamRulesParam(myTeamID, TEXMOD.TEAM_RULE_PARAM)) == TEXMOD.DEFAULT_TEXMOD
	then
		FinishSelector()
	end
end

local function RestartSelector(allMode)
	debugAll = allMode == true
	completed = false
	menuVisible = false
	hoveredIndex = nil
	pendingSelection = nil
	pendingElapsed = 0
	selectionElapsed = 0
	stableElapsed = 0
	elapsed = INITIAL_GRACE
	pollAccumulator = 0

	-- A testing restart deliberately returns the force to the normal Team texture
	-- first, then presents the same selector again. This makes repeated texture
	-- swaps easy to verify without restarting the match.
	Spring.SendLuaRulesMsg(MSG_PREFIX .. TEXMOD.DEFAULT_TEXMOD)
	RefreshEffectiveSide(true)
	if debugAll then
		Spring.Echo("[MCL TexMods] /texmodall opened the debug selector with every configured paint scheme and reset this team to 'Team'.")
	else
		Spring.Echo("[MCL TexMods] /texmod restarted faction paint selection and reset this team to 'Team'.")
	end
end

local function DrawPreview(texmod, x, y, size, hovered)
	local path = previewPaths[texmod]
	if not path then
		return
	end

	local half = size * 0.5
	gl.Color(1, 1, 1, hovered and 1 or 0.92)
	gl.Texture(path)
	gl.TexRect(x - half, y - half, x + half, y + half)
	gl.Texture(false)

	gl.Color(0.9, 0.9, 0.9, hovered and 0.95 or 0.55)
	gl.LineWidth((hovered and 2.0 or 1.0) * scale)
	gl.BeginEnd(GL.LINE_LOOP, function()
		gl.Vertex(x - half, y - half)
		gl.Vertex(x + half, y - half)
		gl.Vertex(x + half, y + half)
		gl.Vertex(x - half, y + half)
	end)
end

local function DrawRingWedge(index, hovered, selected)
	local count = #allowedTexmods
	local sector = twoPi / count
	local centerAngle = (pi * 0.5) + ((index - 1) * sector)
	local half = (sector * 0.5) - WEDGE_GAP_RADIANS
	if half < 0.02 then half = sector * 0.46 end
	local a0 = centerAngle - half
	local a1 = centerAngle + half

	-- Keep every wedge visually neutral: the preview/outline communicates hover
	-- and selection while the wheel itself stays almost completely transparent.
	gl.Color(0.55, 0.55, 0.55, 0.10)

	gl.BeginEnd(GL.TRIANGLE_STRIP, function()
		for step = 0, WEDGE_SEGMENTS do
			local t = step / WEDGE_SEGMENTS
			local a = a0 + ((a1 - a0) * t)
			local c = cos(a)
			local s = sin(a)
			gl.Vertex(centerX + c * innerRadius, centerY + s * innerRadius)
			gl.Vertex(centerX + c * outerRadius, centerY + s * outerRadius)
		end
	end)

	gl.Color(0.82, 0.82, 0.82, hovered and 0.90 or selected and 0.62 or 0.28)
	gl.LineWidth((hovered and 2.0 or 1.0) * scale)
	gl.BeginEnd(GL.LINE_STRIP, function()
		for step = 0, WEDGE_SEGMENTS do
			local t = step / WEDGE_SEGMENTS
			local a = a0 + ((a1 - a0) * t)
			gl.Vertex(centerX + cos(a) * outerRadius, centerY + sin(a) * outerRadius)
		end
	end)

	local texmod = allowedTexmods[index]
	local imageX = centerX + cos(centerAngle) * previewRadius
	local imageY = centerY + sin(centerAngle) * previewRadius
	local imageSize = previewSize
	if count >= 11 then
		imageSize = imageSize * 0.72
	elseif count >= 9 then
		imageSize = imageSize * 0.84
	end
	DrawPreview(texmod, imageX, imageY, imageSize, hovered)

	local labelX = centerX + cos(centerAngle) * textRadius
	local labelY = centerY + sin(centerAngle) * textRadius
	local caption = PrettyName(texmod)
	local fontSize = max(10, floor((count >= 10 and 11 or count >= 8 and 12 or 14) * scale))
	gl.Color(1, 1, 1, 1)
	gl.Text(caption, labelX, labelY - (fontSize * 0.35), fontSize, "oc")
end

local function DrawCenter()
	gl.Color(0.55, 0.55, 0.55, 0.10)
	gl.BeginEnd(GL.TRIANGLE_FAN, function()
		gl.Vertex(centerX, centerY)
		for i = 0, 48 do
			local a = (i / 48) * twoPi
			gl.Vertex(centerX + cos(a) * centerRadius, centerY + sin(a) * centerRadius)
		end
	end)

	gl.Color(0.75, 0.75, 0.75, 0.65)
	gl.LineWidth(1.5 * scale)
	gl.BeginEnd(GL.LINE_LOOP, function()
		for i = 0, 47 do
			local a = (i / 48) * twoPi
			gl.Vertex(centerX + cos(a) * centerRadius, centerY + sin(a) * centerRadius)
		end
	end)

	local centerCaption
	if pendingSelection then
		centerCaption = "APPLYING\n" .. PrettyName(pendingSelection)
	else
		centerCaption = PrettyName(currentSelection) .. "\nCURRENT"
	end

	local line1, line2 = centerCaption:match("([^\n]+)\n(.+)")
	gl.Color(1, 1, 1, 1)
	gl.Text(line1 or centerCaption, centerX, centerY + 5 * scale, 15 * scale, "oc")
	if line2 then
		gl.Color(0.75, 0.75, 0.75, 1)
		gl.Text(line2, centerX, centerY - 16 * scale, 10 * scale, "oc")
	end
end

--------------------------------------------------------------------------------
-- Call-ins
--------------------------------------------------------------------------------

function widget:Initialize()
	local spectator = Spring.GetSpectatingState()
	if spectator or Spring.IsReplay() then
		widgetHandler:RemoveWidget(widget)
		return
	end

	myTeamID = Spring.GetMyTeamID()
	debugAll = false
	RefreshGeometry()
	RefreshEffectiveSide(true)

	-- Do not remove ourselves merely because the engine-side field has no texmods.
	-- In direct spring.exe launches MCL's radial faction selector may still change
	-- startUnit, which is the authoritative faction choice for this system.
	Spring.Echo("[MCL TexMods] Radial paint selector waiting for effective faction/startUnit.")
end

function widget:ViewResize()
	RefreshGeometry()
end

function widget:Update(dt)
	if completed then return end
	dt = dt or 0
	elapsed = elapsed + dt
	stableElapsed = stableElapsed + dt
	pollAccumulator = pollAccumulator + dt

	if pollAccumulator >= SIDE_POLL_INTERVAL then
		pollAccumulator = 0
		RefreshEffectiveSide(false)
		RefreshSelectionState()
	end

	if pendingSelection then
		pendingElapsed = pendingElapsed + dt
		local selected = TEXMOD.NormalizeTexmod(Spring.GetTeamRulesParam(myTeamID, TEXMOD.TEAM_RULE_PARAM))
		if selected == pendingSelection then
			FinishSelector()
			return
		elseif pendingElapsed >= PENDING_TIMEOUT then
			Spring.Echo(string.format(
				"[MCL TexMods] Paint selection '%s' was not accepted; keeping '%s'.",
				tostring(pendingSelection), tostring(selected)
			))
			pendingSelection = nil
			pendingElapsed = 0
		end
	end

	if menuVisible then
		selectionElapsed = selectionElapsed + dt
		if not pendingSelection and selectionElapsed >= SELECTION_TIMEOUT then
			Spring.Echo("[MCL TexMods] Paint selection timed out after 15 seconds; using Team.")
			SelectTexmod(TEXMOD.DEFAULT_TEXMOD)
		end
		return
	end

	if elapsed < INITIAL_GRACE or stableElapsed < SIDE_STABLE_DELAY then
		return
	end

	-- A resolved faction with no configured alternates needs no interaction. Team
	-- remains the default. If MCL has not resolved the selected faction yet, keep
	-- waiting because the direct-launch faction selector may still change startUnit.
	if debugAll or effectiveSideEntry then
		if #allowedTexmods <= 1 then
			Spring.Echo("[MCL TexMods] No alternate texmods for faction '" .. tostring(effectiveSide) .. "'; using Team.")
			FinishSelector()
			return
		end
		selectionElapsed = 0
		menuVisible = true
	end
end

function widget:DrawScreen()
	if not menuVisible or completed then return end

	local mx, my = Spring.GetMouseState()
	hoveredIndex = FindHoveredIndex(mx, my)

	-- Dim only enough to visually separate the radial setup menu from the world.
	gl.Color(0, 0, 0, 0.08)
	gl.Rect(0, 0, vsx, vsy)

	gl.Color(1, 1, 1, 1)
	gl.Text(CanonicalSideCaption(), centerX, centerY + titleOffset, 22 * scale, "oc")
	gl.Color(0.72, 0.72, 0.72, 1)
	gl.Text(debugAll and "Debug mode: showing every paint scheme in Gamedata/texmods.lua" or "Choose a force paint scheme - missing unit textures automatically use Team", centerX, centerY + statusOffset, 12 * scale, "oc")

	for i = 1, #allowedTexmods do
		local texmod = allowedTexmods[i]
		DrawRingWedge(i, i == hoveredIndex, texmod == currentSelection)
	end

	DrawCenter()

	local remaining = max(0, ceil(SELECTION_TIMEOUT - selectionElapsed))
	gl.Color(0.68, 0.68, 0.68, 1)
	gl.Text("LMB SELECT     ESC KEEP CURRENT     TEAM DEFAULT IN " .. remaining .. "s", centerX, centerY - titleOffset + 18 * scale, 11 * scale, "oc")
	gl.Color(1, 1, 1, 1)
	gl.LineWidth(1)
	gl.Texture(false)
end

function widget:MousePress(mx, my, button)
	if not menuVisible or completed then
		return false
	end
	if button ~= 1 then
		return true
	end

	local index = FindHoveredIndex(mx, my)
	if index then
		SelectTexmod(allowedTexmods[index])
	end
	return true
end

function widget:MouseMove(mx, my)
	if menuVisible and not completed then
		hoveredIndex = FindHoveredIndex(mx, my)
	end
end

function widget:KeyPress(key)
	if not menuVisible or completed then
		return false
	end
	if key == 27 then
		FinishSelector()
		return true
	end
	return true
end

function widget:TextCommand(command)
	local normalized = string.lower(tostring(command or ""))
	normalized = string.match(normalized, "^%s*(.-)%s*$") or normalized
	if normalized ~= "texmod" and normalized ~= "texmodall" then
		return false
	end

	local cheatsEnabled = Spring.IsCheatingEnabled and Spring.IsCheatingEnabled() or false
	if not cheatsEnabled then
		Spring.Echo("[MCL TexMods] /" .. normalized .. " requires /cheat.")
		return true
	end

	RestartSelector(normalized == "texmodall")
	return true
end

function widget:IsAbove(mx, my)
	return menuVisible and not completed
end

function widget:GetTooltip(mx, my)
	if not menuVisible or not hoveredIndex then return nil end
	local texmod = allowedTexmods[hoveredIndex]
	local preview = previewPaths[texmod] and " Preview: " .. previewPaths[texmod] .. "." or ""
	if texmod == TEXMOD.DEFAULT_TEXMOD then
		return "Team: use the model's normal *_Team.dds texture." .. preview
	end
	local display = TEXMOD.GetTexmodDisplayName(texmod, texmodData)
	return display .. " (" .. texmod .. "): use *_" .. texmod .. ".dds where available; missing textures fall back to Team." .. preview
end
