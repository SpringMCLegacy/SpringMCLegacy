function widget:GetInfo()
	return {
		name = "MC:L - Custom Fog of War r13",
		desc = "Custom MCL visual fog-of-war with unified Mech vision masks, final-scene depth compositing, explored memory, selected-unit AR HUD, and merged friendly radar coverage",
		author = "zvero + ChatGPT",
		date = "2026",
		license = "GNU GPL v2",
		layer = 1,
		enabled = true,
	}
end

--------------------------------------------------------------------------------
-- Visual configuration
--------------------------------------------------------------------------------

-- Custom FOW. Native Recoil LOS-map rendering is suppressed while this widget
-- is active; actual engine LOS/gameplay state is NOT changed.
local FOG_COLOR = {0.025, 0.030, 0.035}
local UNEXPLORED_FOG_ALPHA = 0.86
local EXPLORED_FOG_ALPHA = 0.62
local VISIBLE_FOG_ALPHA = 0.00

-- Mask edge smoothing. The raw union mask is linearly filtered and then passed
-- through smoothstep(EDGE_LOW, EDGE_HIGH). A wider interval gives a softer edge.
local FOG_EDGE_LOW = 0.08
local FOG_EDGE_HIGH = 0.92
local FOG_EDGE_SAMPLE_RADIUS = 1.25

-- Map-space visibility mask.
local VISION_MASK_MAX_DIM = 1536
local VISION_MASK_MIN_DIM = 256
local VISION_MASK_UPDATE_FRAMES = 1
local EXPLORED_MASK_UPDATE_FRAMES = 5
local ALLIED_MECH_REFRESH_FRAMES = 60
local MASK_CIRCLE_SEGMENTS = 192
local MASK_SECTOR_SEGMENTS = 160

-- Fog compositing is screen-space. The map's g-buffer depth is used to
-- reconstruct the terrain world position for each visible pixel, so there is no
-- second ground surface to z-fight with and no terrain-sized geometry cost.
local MAP_DEPTH_TEXTURE = "$map_gbuffer_zvaltex"
local MODEL_DEPTH_TEXTURE = "$model_gbuffer_zvaltex"
local NATIVE_LOS_TEXTURE = "$info:los"

-- MCL vision geometry. Mech close sight and directional sight are rasterized
-- into the same custom mask so there is no independently filtered join between
-- the close circle and forward sector. Native LOS is still unioned afterward
-- for non-Mech LOS sources.
local SECTOR_RANGE_INSET = 50

-- Selected-Mech AR HUD. These values are intentionally independent of the
-- persistent FOW mask and can be tuned without changing what terrain is visible.
local DRAW_SELECTED_AR_HUD = true
local SECTOR_COLOR = {0.75, 0.75, 0.75}
local SIGHT_COLOR = {0.75, 0.75, 0.75}

local SIGHT_RING_ALPHA = 0.68
local SECTOR_EDGE_ALPHA = 0.72
local OUTER_ARC_ALPHA = 0.76
local CENTERLINE_ALPHA = 0.18
local GUIDE_ARC_ALPHA = 0.13

local HEX_PATTERN_ALPHA = 0.14
local HEX_PATTERN_SIZE = 160

local GLOW_ALPHA = 0.18
local GLOW_WIDTH = 10
local CORE_LINE_WIDTH = 1.7
local GLOW_LINE_WIDTH = 4.5

local FULL_CIRCLE_SEGMENTS = 128
local SECTOR_ARC_SEGMENTS = 64
local SECTOR_RADIAL_SEGMENTS = 12
local SIDE_LINE_SEGMENTS = 24
local ANGULAR_FILL_FEATHER_DEGREES = 6
local GROUND_LIFT = 3.0

local DRAW_CENTERLINE = true
local DRAW_MID_GUIDE_ARC = true
local DRAW_TARGETING_RAILS = true
local TARGETING_RAIL_ALPHA = 0.16
local TARGETING_RAIL_WIDTH = 1.0
local TARGETING_RAIL_OFFSET_DEGREES = 2.25

-- Selected-unit radar visualization. Overlapping selected friendly radar circles
-- are rendered as a geometric union: only the exterior arcs remain visible.
-- This is presentation only; none of these values enter FOW or explored masks.
local RADAR_STYLE = {
	draw = true,
	color = {0.18, 0.92, 0.28},
	ringAlpha = 0.70,
	ringWidth = 1.7,
	glowAlpha = 0.16,
	diffuseWidth = 90,
	diffuseEdgeAlpha = 0.16,
	diffuseInnerAlpha = 0.00,
	hexAlpha = 0.11,
	hexSize = 160,
	ringSegments = 256,
	radialSteps = 16,
}

local ZOOM_FADE_START = 1800
local ZOOM_FADE_REFERENCE = 3600
local ZOOM_FADE_MIN = 0.22

-- Keep the native LOS overlay suppressed if the player presses the normal LOS
-- key while this widget owns FOW presentation.
local ENGINE_LOS_CHECK_INTERVAL = 0.20

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local unitDefInfos = {}
local cockpitPieceCache = {}
local alliedMechs = {}
local lastAlliedRefreshFrame = -999999

local visionMaskTexture = nil
local visionMaskWidth = 0
local visionMaskHeight = 0
local visionMaskReady = false
local visionMaskFailed = false
local visionMaskHasData = false
local lastVisionMaskFrame = -999999
local loggedFirstMaskUpdate = false

local exploredMaskTextures = {nil, nil}
local exploredMaskIndex = 1
local exploredMaskReady = false
local exploredMaskFailed = false
local exploredMaskHasData = false
local lastExploredMaskFrame = -999999
local loggedFirstExploredUpdate = false

local exploredUpdateShader = nil
local exploredUpdateShaderReady = false
local exploredUpdateUniforms = {}

local fogShader = nil
local fogShaderReady = false
local fogUniforms = {}

local depthCopyShader = nil
local depthCopyShaderReady = false
local unitDepthTexture = nil
local featureDepthTexture = nil
local modelDepthWidth = 0
local modelDepthHeight = 0
local unitDepthHasData = false
local featureDepthHasData = false

local engineLosWasActive = false
local engineLosCheckAccumulator = 0

--------------------------------------------------------------------------------
-- Speedups
--------------------------------------------------------------------------------

local spGetSelectedUnitsSorted = Spring.GetSelectedUnitsSorted
local spGetUnitDefID = Spring.GetUnitDefID
local spGetMyTeamID = Spring.GetMyTeamID
local spGetTeamList = Spring.GetTeamList
local spGetTeamUnits = Spring.GetTeamUnits
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetUnitHeading = Spring.GetUnitHeading
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitPieceMap = Spring.GetUnitPieceMap
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitTransporter = Spring.GetUnitTransporter
local spGetGroundHeight = Spring.GetGroundHeight
local spGetCameraPosition = Spring.GetCameraPosition
local spGetGameFrame = Spring.GetGameFrame
local spGetMapDrawMode = Spring.GetMapDrawMode
local spSendCommands = Spring.SendCommands
local spIsGUIHidden = Spring.IsGUIHidden

local glBeginEnd = gl.BeginEnd
local glBlending = gl.Blending
local glClear = gl.Clear
local glColor = gl.Color
local glCreateShader = gl.CreateShader
local glCreateTexture = gl.CreateTexture
local glDeleteShader = gl.DeleteShader
local glDeleteTexture = gl.DeleteTexture
local glDepthMask = gl.DepthMask
local glDepthTest = gl.DepthTest
local glGetShaderLog = gl.GetShaderLog
local glGetUniformLocation = gl.GetUniformLocation
local glGetViewSizes = gl.GetViewSizes
local glLineStipple = gl.LineStipple
local glLineWidth = gl.LineWidth
local glLoadIdentity = gl.LoadIdentity
local glMatrixMode = gl.MatrixMode
local glOrtho = gl.Ortho
local glPopAttrib = gl.PopAttrib
local glPopMatrix = gl.PopMatrix
local glPushAttrib = gl.PushAttrib
local glPushMatrix = gl.PushMatrix
local glRenderToTexture = gl.RenderToTexture
local glTexCoord = gl.TexCoord
local glTexture = gl.Texture
local glUniform = gl.Uniform
local glUseShader = gl.UseShader
local glVertex = gl.Vertex
local glViewport = gl.Viewport

local sin = math.sin
local cos = math.cos
local rad = math.rad
local sqrt = math.sqrt
local max = math.max
local min = math.min
local pi = math.pi

local TWO_PI = 2 * pi
local HEADING_TO_RAD = TWO_PI / 65536

local modOptions = Spring.GetModOptions() or {}
local RADAR = tonumber(modOptions.sectorrange) or 1000
local LOS = tonumber(modOptions.mechsight) or 400
local HEX_TEXTURE = (VFS and VFS.FileExists and VFS.FileExists("bitmaps/maphex.png")) and "bitmaps/maphex.png" or false

--------------------------------------------------------------------------------
-- Custom FOW shader
--------------------------------------------------------------------------------

local FOG_VERTEX_SHADER = [[
#version 130

varying vec2 vScreenUV;

void main()
{
	vScreenUV = gl_MultiTexCoord0.st;
	gl_Position = gl_Vertex;
}
]]

local FOG_FRAGMENT_SHADER = [[
#version 130

uniform sampler2D sectorMaskTex;
uniform sampler2D exploredMaskTex;
uniform sampler2D mapDepthTex;
uniform sampler2D nativeLosTex;
uniform sampler2D unitDepthTex;
uniform sampler2D featureDepthTex;
uniform vec2 mapSize;
uniform vec2 sectorMaskTexelSize;
uniform vec3 fogColor;
uniform float unexploredFogAlpha;
uniform float exploredFogAlpha;
uniform float visibleFogAlpha;
uniform float edgeLow;
uniform float edgeHigh;
uniform float edgeSampleRadius;
uniform float nativeLosAvailable;
uniform float unitDepthAvailable;
uniform float featureDepthAvailable;

varying vec2 vScreenUV;

float sampleSmoothedMask(sampler2D tex, vec2 uv, vec2 texelSize)
{
	vec2 off = texelSize * edgeSampleRadius;

	float c = texture2D(tex, uv).r * 4.0;
	c += texture2D(tex, clamp(uv + vec2(-off.x, 0.0), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2( off.x, 0.0), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2(0.0, -off.y), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2(0.0,  off.y), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2(-off.x, -off.y), 0.0, 1.0)).r;
	c += texture2D(tex, clamp(uv + vec2( off.x, -off.y), 0.0, 1.0)).r;
	c += texture2D(tex, clamp(uv + vec2(-off.x,  off.y), 0.0, 1.0)).r;
	c += texture2D(tex, clamp(uv + vec2( off.x,  off.y), 0.0, 1.0)).r;
	return c * 0.0625;
}

float getSectorVisibility(vec2 uv)
{
	float raw = texture2D(sectorMaskTex, uv).r;
	float filtered = sampleSmoothedMask(sectorMaskTex, uv, sectorMaskTexelSize);
	return smoothstep(edgeLow, edgeHigh, max(raw, filtered));
}

float getNativeVisibility(vec2 uv)
{
	if (nativeLosAvailable < 0.5) {
		return 0.0;
	}
	vec2 nativeTexelSize = 1.0 / vec2(textureSize(nativeLosTex, 0));
	float raw = texture2D(nativeLosTex, uv).r;
	float filtered = sampleSmoothedMask(nativeLosTex, uv, nativeTexelSize);
	return smoothstep(edgeLow, edgeHigh, max(raw, filtered));
}

float chooseNearestDepth(vec2 uv)
{
	float depth = texture2D(mapDepthTex, uv).r;

	if (unitDepthAvailable >= 0.5) {
		float unitDepth = texture2D(unitDepthTex, uv).r;
		if (unitDepth < 0.999999) {
			depth = min(depth, unitDepth);
		}
	}

	if (featureDepthAvailable >= 0.5) {
		float featureDepth = texture2D(featureDepthTex, uv).r;
		if (featureDepth < 0.999999) {
			depth = min(depth, featureDepth);
		}
	}

	return depth;
}

void main()
{
	// Fog is now composited after opaque world models. Choosing the nearest map,
	// unit, or feature depth gives the fog shader the actual visible surface for
	// this screen pixel instead of forcing antialiased model edges to blend over
	// terrain that was darkened earlier in the frame.
	float depth = chooseNearestDepth(vScreenUV);

	if (depth >= 0.999999) {
		discard;
	}

	vec4 clipPos = vec4(
		vScreenUV.x * 2.0 - 1.0,
		vScreenUV.y * 2.0 - 1.0,
		depth,
		1.0
	);

	vec4 worldPos = gl_ModelViewProjectionMatrixInverse * clipPos;
	if (abs(worldPos.w) < 0.000001) {
		discard;
	}
	worldPos /= worldPos.w;

	if (worldPos.x < 0.0 || worldPos.z < 0.0 ||
		worldPos.x > mapSize.x || worldPos.z > mapSize.y) {
		discard;
	}

	vec2 mapUV = worldPos.xz / max(mapSize, vec2(1.0));
	float sectorVisibility = getSectorVisibility(mapUV);
	float nativeVisibility = getNativeVisibility(mapUV);
	float currentVisibility = max(sectorVisibility, nativeVisibility);
	float exploredVisibility = max(texture2D(exploredMaskTex, mapUV).r, currentVisibility);

	float alpha = mix(unexploredFogAlpha, exploredFogAlpha, exploredVisibility);
	alpha = mix(alpha, visibleFogAlpha, currentVisibility);

	if (alpha <= 0.001) {
		discard;
	}

	gl_FragColor = vec4(fogColor, alpha);
}
]]

local DEPTH_COPY_FRAGMENT_SHADER = [[
#version 130

uniform sampler2D sourceDepthTex;
varying vec2 vScreenUV;

void main()
{
	float depth = texture2D(sourceDepthTex, vScreenUV).r;
	gl_FragColor = vec4(depth, 0.0, 0.0, 1.0);
}
]]

local EXPLORED_UPDATE_VERTEX_SHADER = [[
#version 130

varying vec2 vUV;

void main()
{
	vUV = gl_MultiTexCoord0.st;
	gl_Position = gl_Vertex;
}
]]

local EXPLORED_UPDATE_FRAGMENT_SHADER = [[
#version 130

uniform sampler2D sectorMaskTex;
uniform sampler2D previousExploredTex;
uniform sampler2D nativeLosTex;
uniform vec2 sectorMaskTexelSize;
uniform float edgeLow;
uniform float edgeHigh;
uniform float edgeSampleRadius;
uniform float nativeLosAvailable;
uniform float previousExploredAvailable;

varying vec2 vUV;

float sampleSmoothedMask(sampler2D tex, vec2 uv, vec2 texelSize)
{
	vec2 off = texelSize * edgeSampleRadius;

	float c = texture2D(tex, uv).r * 4.0;
	c += texture2D(tex, clamp(uv + vec2(-off.x, 0.0), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2( off.x, 0.0), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2(0.0, -off.y), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2(0.0,  off.y), 0.0, 1.0)).r * 2.0;
	c += texture2D(tex, clamp(uv + vec2(-off.x, -off.y), 0.0, 1.0)).r;
	c += texture2D(tex, clamp(uv + vec2( off.x, -off.y), 0.0, 1.0)).r;
	c += texture2D(tex, clamp(uv + vec2(-off.x,  off.y), 0.0, 1.0)).r;
	c += texture2D(tex, clamp(uv + vec2( off.x,  off.y), 0.0, 1.0)).r;
	return c * 0.0625;
}

float getSectorVisibility(vec2 uv)
{
	float raw = texture2D(sectorMaskTex, uv).r;
	float filtered = sampleSmoothedMask(sectorMaskTex, uv, sectorMaskTexelSize);
	float c = max(raw, filtered);
	return smoothstep(edgeLow, edgeHigh, c);
}

void main()
{
	float sectorVisibility = getSectorVisibility(vUV);
	float nativeVisibility = 0.0;
	if (nativeLosAvailable >= 0.5) {
		vec2 nativeTexelSize = 1.0 / vec2(textureSize(nativeLosTex, 0));
		float nativeRaw = texture2D(nativeLosTex, vUV).r;
		float nativeFiltered = sampleSmoothedMask(nativeLosTex, vUV, nativeTexelSize);
		float nativeSample = max(nativeRaw, nativeFiltered);
		nativeVisibility = smoothstep(edgeLow, edgeHigh, nativeSample);
	}
	float currentVisibility = max(sectorVisibility, nativeVisibility);
	float previousExplored = 0.0;
	if (previousExploredAvailable >= 0.5) {
		previousExplored = texture2D(previousExploredTex, vUV).r;
	}
	float exploredVisibility = max(previousExplored, currentVisibility);
	gl_FragColor = vec4(exploredVisibility, exploredVisibility, exploredVisibility, 1.0);
}
]]

--------------------------------------------------------------------------------
-- General helpers
--------------------------------------------------------------------------------

local function Clamp01(value)
	if value <= 0 then
		return 0
	elseif value >= 1 then
		return 1
	end
	return value
end

local function GetUnitDefHalfAngle(unitDef)
	local sectorAngle = unitDef.customParams and tonumber(unitDef.customParams.sectorangle)
	if sectorAngle and sectorAngle > 0 then
		return rad(sectorAngle * 0.5)
	end
	return nil
end

local function ResolveCockpitPose(unitID, unitDefID)
	local pieceID = cockpitPieceCache[unitDefID]

	if pieceID == nil then
		local pieceMap = spGetUnitPieceMap(unitID)
		pieceID = pieceMap and pieceMap["cockpit"] or false
		cockpitPieceCache[unitDefID] = pieceID
	end

	if pieceID then
		local x, y, z, dx, dy, dz = spGetUnitPiecePosDir(unitID, pieceID)
		if x and dx and dz then
			return x, z, math.atan2(dx, dz)
		end
	end

	local x, y, z = spGetUnitPosition(unitID)
	if not x then
		return nil
	end

	local heading = spGetUnitHeading(unitID) or 0
	return x, z, heading * HEADING_TO_RAD
end

local function GetZoomAlphaScale(x, y, z)
	if not spGetCameraPosition then
		return 1
	end

	local cx, cy, cz = spGetCameraPosition()
	if not cx then
		return 1
	end

	local dx = x - cx
	local dy = y - cy
	local dz = z - cz
	local distance = sqrt(dx * dx + dy * dy + dz * dz)

	if distance <= ZOOM_FADE_START then
		return 1
	end

	local scale = ZOOM_FADE_REFERENCE / distance
	return max(ZOOM_FADE_MIN, min(1, scale))
end

local function GroundVertex(cx, cz, angle, radius)
	local x = cx + sin(angle) * radius
	local z = cz + cos(angle) * radius
	local y = spGetGroundHeight(x, z) + GROUND_LIFT
	return x, y, z
end

--------------------------------------------------------------------------------
-- Engine LOS visual suppression
--------------------------------------------------------------------------------

local function SuppressNativeLosOverlay()
	if not spGetMapDrawMode or not spSendCommands then
		return
	end

	if spGetMapDrawMode() == "los" then
		spSendCommands("showstandard")
	end
end

--------------------------------------------------------------------------------
-- Allied Mech directional-sector extension mask
--------------------------------------------------------------------------------

local function RefreshAlliedMechs(force)
	local frame = (spGetGameFrame and spGetGameFrame()) or 0
	if not force and frame - lastAlliedRefreshFrame < ALLIED_MECH_REFRESH_FRAMES then
		return
	end

	lastAlliedRefreshFrame = frame
	alliedMechs = {}

	if not spGetTeamList or not spGetTeamUnits then
		return
	end

	local myTeamID = spGetMyTeamID and spGetMyTeamID() or nil
	local teams = spGetTeamList() or {}

	for ti = 1, #teams do
		local teamID = teams[ti]
		local allied = (teamID == myTeamID)

		if not allied and myTeamID and spAreTeamsAllied then
			allied = spAreTeamsAllied(myTeamID, teamID)
		end

		if allied then
			local units = spGetTeamUnits(teamID) or {}
			for ui = 1, #units do
				local unitID = units[ui]
				local unitDefID = spGetUnitDefID(unitID)
				if unitDefID and unitDefInfos[unitDefID] then
					alliedMechs[#alliedMechs + 1] = {
						unitID = unitID,
						unitDefID = unitDefID,
					}
				end
			end
		end
	end
end

local function DrawMaskCircle(cx, cz, radius)
	glBeginEnd(GL.TRIANGLE_FAN, function()
		glVertex(cx, cz, 0)
		for i = 0, MASK_CIRCLE_SEGMENTS do
			local angle = TWO_PI * (i / MASK_CIRCLE_SEGMENTS)
			glVertex(cx + sin(angle) * radius, cz + cos(angle) * radius, 0)
		end
	end)
end

local function DrawMaskSector(cx, cz, heading, halfAngle, innerRadius, outerRadius)
	if outerRadius <= innerRadius then
		return
	end

	local startAngle = heading - halfAngle
	local fullAngle = halfAngle * 2

	glBeginEnd(GL.TRIANGLE_STRIP, function()
		for i = 0, MASK_SECTOR_SEGMENTS do
			local angle = startAngle + fullAngle * (i / MASK_SECTOR_SEGMENTS)
			glVertex(cx + sin(angle) * innerRadius, cz + cos(angle) * innerRadius, 0)
			glVertex(cx + sin(angle) * outerRadius, cz + cos(angle) * outerRadius, 0)
		end
	end)
end

local function InitializeVisionMaskTexture()
	if not glCreateTexture or not glRenderToTexture then
		return false
	end

	local mapX = max(1, Game.mapSizeX)
	local mapZ = max(1, Game.mapSizeZ)
	local longest = max(mapX, mapZ)
	local scale = VISION_MASK_MAX_DIM / longest

	visionMaskWidth = max(VISION_MASK_MIN_DIM, math.floor(mapX * scale + 0.5))
	visionMaskHeight = max(VISION_MASK_MIN_DIM, math.floor(mapZ * scale + 0.5))
	visionMaskWidth = min(VISION_MASK_MAX_DIM, visionMaskWidth)
	visionMaskHeight = min(VISION_MASK_MAX_DIM, visionMaskHeight)

	local ok, texture = pcall(
		glCreateTexture,
		visionMaskWidth,
		visionMaskHeight,
		{
			format = GL.RGBA8,
			min_filter = GL.LINEAR,
			mag_filter = GL.LINEAR,
			wrap_s = GL.CLAMP_TO_EDGE,
			wrap_t = GL.CLAMP_TO_EDGE,
			fbo = true,
		}
	)

	if not ok or not texture then
		Spring.Echo("[MCL FOW r13] ERROR: could not create visibility-mask FBO texture.")
		visionMaskFailed = true
		return false
	end

	visionMaskTexture = texture
	visionMaskReady = true
	Spring.Echo("[MCL FOW r13] Visibility mask created at " .. visionMaskWidth .. "x" .. visionMaskHeight .. ".")
	return true
end

local function RenderVisionMaskContents()
	if glPushAttrib then
		glPushAttrib(GL.ALL_ATTRIB_BITS)
	end

	glViewport(0, 0, visionMaskWidth, visionMaskHeight)
	glClear(GL.COLOR_BUFFER_BIT, 0, 0, 0, 0)
	glDepthTest(false)
	glDepthMask(false)
	glTexture(false)
	glBlending(GL.ONE, GL.ONE)
	glColor(1, 1, 1, 1)

	glMatrixMode(GL.PROJECTION)
	glPushMatrix()
	glLoadIdentity()
	glOrtho(0, Game.mapSizeX, 0, Game.mapSizeZ, -1, 1)

	glMatrixMode(GL.MODELVIEW)
	glPushMatrix()
	glLoadIdentity()

	for i = 1, #alliedMechs do
		local entry = alliedMechs[i]
		if spGetUnitDefID(entry.unitID) == entry.unitDefID then
			-- A transported Mech (for example while descending inside a dropship)
			-- must not project its directional cockpit sector through the transport.
			local transporterID = spGetUnitTransporter and spGetUnitTransporter(entry.unitID)
			if not transporterID then
				local info = unitDefInfos[entry.unitDefID]
				local cx, cz, heading = ResolveCockpitPose(entry.unitID, entry.unitDefID)

				if info and cx then
					local sectorRange = (spGetUnitRulesParam(entry.unitID, "sectorradius") or RADAR) - SECTOR_RANGE_INSET
					sectorRange = max(LOS + 1, sectorRange)

					DrawMaskCircle(cx, cz, LOS)
					DrawMaskSector(cx, cz, heading, info.halfAngle, 0, sectorRange)
				end
			end
		end
	end

	glPopMatrix()
	glMatrixMode(GL.PROJECTION)
	glPopMatrix()
	glMatrixMode(GL.MODELVIEW)

	if glPopAttrib then
		glPopAttrib()
	end
end

local function UpdateVisionMask()
	if not visionMaskReady or visionMaskFailed then
		return false
	end

	local frame = (spGetGameFrame and spGetGameFrame()) or 0
	RefreshAlliedMechs(false)

	if frame - lastVisionMaskFrame < VISION_MASK_UPDATE_FRAMES then
		return true
	end

	lastVisionMaskFrame = frame
	local ok, err = pcall(glRenderToTexture, visionMaskTexture, RenderVisionMaskContents)
	if not ok then
		Spring.Echo("[MCL FOW r13] ERROR: visibility-mask update failed: " .. tostring(err))
		visionMaskFailed = true
		visionMaskHasData = false
		return false
	end

	visionMaskHasData = true
	if not loggedFirstMaskUpdate then
		loggedFirstMaskUpdate = true
		Spring.Echo("[MCL FOW r13] First visibility-mask render completed successfully in DrawGenesis().")
	end

	return true
end

local function InitializeExploredMaskTextures()
	if not visionMaskReady or not glCreateTexture then
		return false
	end

	for i = 1, 2 do
		local ok, texture = pcall(
			glCreateTexture,
			visionMaskWidth,
			visionMaskHeight,
			{
				format = GL.RGBA8,
				min_filter = GL.LINEAR,
				mag_filter = GL.LINEAR,
				wrap_s = GL.CLAMP_TO_EDGE,
				wrap_t = GL.CLAMP_TO_EDGE,
				fbo = true,
			}
		)

		if not ok or not texture then
			Spring.Echo("[MCL FOW r13] ERROR: could not create explored-mask FBO texture " .. i .. ".")
			exploredMaskFailed = true
			return false
		end

		exploredMaskTextures[i] = texture
	end

	exploredMaskReady = true
	return true
end

local function InitializeExploredUpdateShader()
	if not exploredMaskReady or not glCreateShader or not glUseShader or not glGetUniformLocation or not glUniform then
		return false
	end

	exploredUpdateShader = glCreateShader({
		vertex = EXPLORED_UPDATE_VERTEX_SHADER,
		fragment = EXPLORED_UPDATE_FRAGMENT_SHADER,
		uniformInt = {
			sectorMaskTex = 0,
			nativeLosTex = 1,
			previousExploredTex = 2,
		},
		uniformFloat = {
			sectorMaskTexelSize = {1 / visionMaskWidth, 1 / visionMaskHeight},
			edgeLow = FOG_EDGE_LOW,
			edgeHigh = FOG_EDGE_HIGH,
			edgeSampleRadius = FOG_EDGE_SAMPLE_RADIUS,
			nativeLosAvailable = 1.0,
			previousExploredAvailable = 0.0,
		},
	})

	if not exploredUpdateShader then
		Spring.Echo("[MCL FOW r13] ERROR: explored-mask update shader failed to compile.")
		if glGetShaderLog then
			local log = glGetShaderLog()
			if log and log ~= "" then
				Spring.Echo(log)
			end
		end
		return false
	end

	local names = {
		"sectorMaskTexelSize",
		"edgeLow",
		"edgeHigh",
		"edgeSampleRadius",
		"nativeLosAvailable",
		"previousExploredAvailable",
	}

	for i = 1, #names do
		local name = names[i]
		local location = glGetUniformLocation(exploredUpdateShader, name)
		if type(location) ~= "number" or location < 0 then
			Spring.Echo("[MCL FOW r13] ERROR: missing explored-mask shader uniform " .. name .. ".")
			if glDeleteShader then
				glDeleteShader(exploredUpdateShader)
			end
			exploredUpdateShader = nil
			exploredUpdateUniforms = {}
			return false
		end
		
		exploredUpdateUniforms[name] = location
	end

	exploredUpdateShaderReady = true
	Spring.Echo("[MCL FOW r13] Explored-memory mask update shader active.")
	return true
end

local loggedNativeLosBindFailure = false

local function DrawFullscreenUnitQuad()
	glBeginEnd(GL.QUADS, function()
		glTexCoord(0, 0)
		glVertex(-1, -1, 0, 1)
		glTexCoord(1, 0)
		glVertex( 1, -1, 0, 1)
		glTexCoord(1, 1)
		glVertex( 1,  1, 0, 1)
		glTexCoord(0, 1)
		glVertex(-1,  1, 0, 1)
	end)
end

local function RenderExploredMaskContents(previousExploredTexture)
	if glPushAttrib then
		glPushAttrib(GL.ALL_ATTRIB_BITS)
	end

	glViewport(0, 0, visionMaskWidth, visionMaskHeight)
	glClear(GL.COLOR_BUFFER_BIT, 0, 0, 0, 0)
	glDepthTest(false)
	glDepthMask(false)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	glColor(1, 1, 1, 1)

	local nativeLosAvailable = 0.0
	if not glTexture(0, visionMaskTexture) then
		if glPopAttrib then
			glPopAttrib()
		end
		return false
	end
	if glTexture(1, NATIVE_LOS_TEXTURE) then
		nativeLosAvailable = 1.0
	else
		glTexture(1, false)
		if not loggedNativeLosBindFailure then
			loggedNativeLosBindFailure = true
			Spring.Echo("[MCL FOW r13] WARNING: could not bind " .. NATIVE_LOS_TEXTURE .. "; explored memory will currently use Mech sectors only.")
		end
	end
	local previousExploredAvailable = 0.0
	if previousExploredTexture then
		previousExploredAvailable = 1.0
		glTexture(2, previousExploredTexture)
	else
		glTexture(2, false)
	end

	if glUseShader(exploredUpdateShader) then
		glUniform(exploredUpdateUniforms.sectorMaskTexelSize, 1 / visionMaskWidth, 1 / visionMaskHeight)
		glUniform(exploredUpdateUniforms.edgeLow, FOG_EDGE_LOW)
		glUniform(exploredUpdateUniforms.edgeHigh, FOG_EDGE_HIGH)
		glUniform(exploredUpdateUniforms.edgeSampleRadius, FOG_EDGE_SAMPLE_RADIUS)
		glUniform(exploredUpdateUniforms.nativeLosAvailable, nativeLosAvailable)
		glUniform(exploredUpdateUniforms.previousExploredAvailable, previousExploredAvailable)
		DrawFullscreenUnitQuad()
		glUseShader(0)
	end

	glTexture(2, false)
	glTexture(1, false)
	glTexture(0, false)

	if glPopAttrib then
		glPopAttrib()
	end
	return true
end

local function UpdateExploredMask()
	if not exploredMaskReady or exploredMaskFailed or not visionMaskHasData or not exploredUpdateShaderReady then
		return false
	end

	local frame = (spGetGameFrame and spGetGameFrame()) or 0
	if frame - lastExploredMaskFrame < EXPLORED_MASK_UPDATE_FRAMES then
		return true
	end

	lastExploredMaskFrame = frame
	local readIndex = exploredMaskIndex
	local writeIndex = (readIndex == 1) and 2 or 1
	local readTexture = exploredMaskHasData and exploredMaskTextures[readIndex] or nil
	local writeTexture = exploredMaskTextures[writeIndex]

	local ok, err = pcall(glRenderToTexture, writeTexture, function()
		RenderExploredMaskContents(readTexture)
	end)
	if not ok then
		Spring.Echo("[MCL FOW r13] ERROR: explored-mask update failed: " .. tostring(err))
		exploredMaskFailed = true
		exploredMaskHasData = false
		return false
	end

	exploredMaskIndex = writeIndex
	exploredMaskHasData = true
	if not loggedFirstExploredUpdate then
		loggedFirstExploredUpdate = true
		Spring.Echo("[MCL FOW r13] First explored-memory update completed successfully in DrawGenesis().")
	end

	return true
end

--------------------------------------------------------------------------------
-- Deferred model-depth capture
--------------------------------------------------------------------------------

local function DeleteModelDepthCaptureTextures()
	if unitDepthTexture and glDeleteTexture then
		glDeleteTexture(unitDepthTexture)
	end
	if featureDepthTexture and glDeleteTexture then
		glDeleteTexture(featureDepthTexture)
	end
	unitDepthTexture = nil
	featureDepthTexture = nil
	unitDepthHasData = false
	featureDepthHasData = false
end

local function InitializeModelDepthCaptureTextures()
	if not glCreateTexture or not glRenderToTexture then
		return false
	end

	local width, height = 0, 0
	if glGetViewSizes then
		width, height = glGetViewSizes()
	end
	if not width or width <= 0 or not height or height <= 0 then
		width, height = Spring.GetViewGeometry()
	end
	width = max(1, math.floor(width or 1))
	height = max(1, math.floor(height or 1))

	DeleteModelDepthCaptureTextures()

	local function CreateDepthTexture()
		local ok, texture = pcall(
			glCreateTexture,
			width,
			height,
			{
				format = GL.R32F,
				min_filter = GL.NEAREST,
				mag_filter = GL.NEAREST,
				wrap_s = GL.CLAMP_TO_EDGE,
				wrap_t = GL.CLAMP_TO_EDGE,
				fbo = true,
			}
		)
		if ok then
			return texture
		end
		return nil
	end

	unitDepthTexture = CreateDepthTexture()
	featureDepthTexture = CreateDepthTexture()
	if not unitDepthTexture or not featureDepthTexture then
		DeleteModelDepthCaptureTextures()
		Spring.Echo("[MCL FOW r13] WARNING: could not create model-depth capture textures; final FOW will fall back to map depth where model depth is unavailable.")
		return false
	end

	modelDepthWidth = width
	modelDepthHeight = height
	Spring.Echo("[MCL FOW r13] Model-depth capture textures created at " .. width .. "x" .. height .. ".")
	return true
end

local function InitializeDepthCopyShader()
	if not glCreateShader or not glUseShader then
		return false
	end

	depthCopyShader = glCreateShader({
		vertex = FOG_VERTEX_SHADER,
		fragment = DEPTH_COPY_FRAGMENT_SHADER,
		uniformInt = {
			sourceDepthTex = 0,
		},
	})

	if not depthCopyShader then
		Spring.Echo("[MCL FOW r13] WARNING: model-depth copy shader failed to compile.")
		if glGetShaderLog then
			local log = glGetShaderLog()
			if log and log ~= "" then
				Spring.Echo(log)
			end
		end
		return false
	end

	depthCopyShaderReady = true
	return true
end

local function DrawClipSpaceQuad()
	glBeginEnd(GL.QUADS, function()
		glTexCoord(0, 0)
		glVertex(-1, -1, 0, 1)
		glTexCoord(1, 0)
		glVertex( 1, -1, 0, 1)
		glTexCoord(1, 1)
		glVertex( 1,  1, 0, 1)
		glTexCoord(0, 1)
		glVertex(-1,  1, 0, 1)
	end)
end

local function ClearCapturedDepthTexture(texture)
	if not texture then
		return
	end
	pcall(glRenderToTexture, texture, function()
		if glPushAttrib then
			glPushAttrib(GL.ALL_ATTRIB_BITS)
		end

		glViewport(0, 0, modelDepthWidth, modelDepthHeight)
		glDepthTest(false)
		glDepthMask(false)
		glBlending(false)
		glColor(1, 1, 1, 1)
		glClear(GL.COLOR_BUFFER_BIT, 1, 0, 0, 1)

		if glPopAttrib then
			glPopAttrib()
		end
	end)
end

local function ClearModelDepthCaptures()
	unitDepthHasData = false
	featureDepthHasData = false
	ClearCapturedDepthTexture(unitDepthTexture)
	ClearCapturedDepthTexture(featureDepthTexture)
end

local function CaptureCurrentModelDepth(targetTexture)
	if not depthCopyShaderReady or not targetTexture then
		return false
	end

	local didCopy = false
	local ok, err = pcall(glRenderToTexture, targetTexture, function()
		if glPushAttrib then
			glPushAttrib(GL.ALL_ATTRIB_BITS)
		end

		glViewport(0, 0, modelDepthWidth, modelDepthHeight)
		glDepthTest(false)
		glDepthMask(false)
		glBlending(false)
		glColor(1, 1, 1, 1)

		local depthBound = glTexture(0, MODEL_DEPTH_TEXTURE)
		if depthBound and glUseShader(depthCopyShader) then
			DrawClipSpaceQuad()
			glUseShader(0)
			didCopy = true
		end

		glUseShader(0)
		glTexture(0, false)

		if glPopAttrib then
			glPopAttrib()
		end
	end)

	if not ok then
		Spring.Echo("[MCL FOW r13] WARNING: model-depth capture failed: " .. tostring(err))
		return false
	end
	return didCopy
end

--------------------------------------------------------------------------------
-- Fog compositor
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Explored-memory update shader
--------------------------------------------------------------------------------


local loggedDepthTextureFailure = false

local function InitializeFogShader()
	if not visionMaskReady or not glCreateShader or not glUseShader or not glGetUniformLocation or not glUniform then
		return false
	end

	fogShader = glCreateShader({
		vertex = FOG_VERTEX_SHADER,
		fragment = FOG_FRAGMENT_SHADER,
		uniformInt = {
			sectorMaskTex = 0,
			exploredMaskTex = 1,
			mapDepthTex = 2,
			nativeLosTex = 3,
			unitDepthTex = 4,
			featureDepthTex = 5,
		},
		uniformFloat = {
			mapSize = {Game.mapSizeX, Game.mapSizeZ},
			sectorMaskTexelSize = {1 / visionMaskWidth, 1 / visionMaskHeight},
			fogColor = {FOG_COLOR[1], FOG_COLOR[2], FOG_COLOR[3]},
			unexploredFogAlpha = UNEXPLORED_FOG_ALPHA,
			exploredFogAlpha = EXPLORED_FOG_ALPHA,
			visibleFogAlpha = VISIBLE_FOG_ALPHA,
			edgeLow = FOG_EDGE_LOW,
			edgeHigh = FOG_EDGE_HIGH,
			edgeSampleRadius = FOG_EDGE_SAMPLE_RADIUS,
			nativeLosAvailable = 1.0,
			unitDepthAvailable = 0.0,
			featureDepthAvailable = 0.0,
		},
	})

	if not fogShader then
		Spring.Echo("[MCL FOW r13] ERROR: screen-space FOW shader failed to compile.")
		if glGetShaderLog then
			local log = glGetShaderLog()
			if log and log ~= "" then
				Spring.Echo(log)
			end
		end
		return false
	end

	local names = {
		"mapSize",
		"sectorMaskTexelSize",
		"fogColor",
		"unexploredFogAlpha",
		"exploredFogAlpha",
		"visibleFogAlpha",
		"edgeLow",
		"edgeHigh",
		"edgeSampleRadius",
		"nativeLosAvailable",
		"unitDepthAvailable",
		"featureDepthAvailable",
	}

	for i = 1, #names do
		local name = names[i]
		local location = glGetUniformLocation(fogShader, name)
		if type(location) ~= "number" or location < 0 then
			Spring.Echo("[MCL FOW r13] ERROR: missing FOW shader uniform " .. name .. ".")
			if glDeleteShader then
				glDeleteShader(fogShader)
			end
			fogShader = nil
			fogUniforms = {}
			return false
		end
		fogUniforms[name] = location
	end

	fogShaderReady = true
	Spring.Echo("[MCL FOW r13] Screen-space depth-reconstructed GLSL 1.30 fog compositor active; camera inverse supplied by compatibility GLSL state.")
	return true
end

local function ValidateScreenFogRenderer()
	Spring.Echo("[MCL FOW r13] Screen-space fog renderer ready; using GLSL compatibility inverse camera matrix.")
	Spring.Echo("[MCL FOW r13] Final-scene fog compositor will combine map, captured unit, and captured feature depth.")
	Spring.Echo("[MCL FOW r13] Unified Mech circle/sector mask and transport suppression active.")
	Spring.Echo("[MCL FOW r13] Selected-unit visual radar rings active; radar graphics do not contribute to FOW masks.")
	return true
end

local function BeginFogShader()
	if not fogShaderReady or not fogShader or not visionMaskTexture or not exploredMaskReady then
		return false
	end

	if not glTexture(0, visionMaskTexture) then
		return false
	end
	if not glTexture(1, exploredMaskTextures[exploredMaskIndex]) then
		glTexture(0, false)
		return false
	end
	if not glTexture(2, MAP_DEPTH_TEXTURE) then
		glTexture(1, false)
		glTexture(0, false)
		if not loggedDepthTextureFailure then
			loggedDepthTextureFailure = true
			Spring.Echo("[MCL FOW r13] ERROR: could not bind " .. MAP_DEPTH_TEXTURE .. "; final screen-space FOW cannot render.")
		end
		return false
	end

	local nativeLosAvailable = 0.0
	if glTexture(3, NATIVE_LOS_TEXTURE) then
		nativeLosAvailable = 1.0
	else
		glTexture(3, false)
		if not loggedNativeLosBindFailure then
			loggedNativeLosBindFailure = true
			Spring.Echo("[MCL FOW r13] WARNING: could not bind " .. NATIVE_LOS_TEXTURE .. "; only custom Mech sight will contribute to current visibility.")
		end
	end

	local unitAvailable = 0.0
	if unitDepthHasData and unitDepthTexture and glTexture(4, unitDepthTexture) then
		unitAvailable = 1.0
	else
		glTexture(4, false)
	end

	local featureAvailable = 0.0
	if featureDepthHasData and featureDepthTexture and glTexture(5, featureDepthTexture) then
		featureAvailable = 1.0
	else
		glTexture(5, false)
	end

	if not glUseShader(fogShader) then
		glTexture(5, false)
		glTexture(4, false)
		glTexture(3, false)
		glTexture(2, false)
		glTexture(1, false)
		glTexture(0, false)
		return false
	end

	glUniform(fogUniforms.mapSize, Game.mapSizeX, Game.mapSizeZ)
	glUniform(fogUniforms.sectorMaskTexelSize, 1 / visionMaskWidth, 1 / visionMaskHeight)
	glUniform(fogUniforms.fogColor, FOG_COLOR[1], FOG_COLOR[2], FOG_COLOR[3])
	glUniform(fogUniforms.unexploredFogAlpha, UNEXPLORED_FOG_ALPHA)
	glUniform(fogUniforms.exploredFogAlpha, EXPLORED_FOG_ALPHA)
	glUniform(fogUniforms.visibleFogAlpha, VISIBLE_FOG_ALPHA)
	glUniform(fogUniforms.edgeLow, FOG_EDGE_LOW)
	glUniform(fogUniforms.edgeHigh, FOG_EDGE_HIGH)
	glUniform(fogUniforms.edgeSampleRadius, FOG_EDGE_SAMPLE_RADIUS)
	glUniform(fogUniforms.nativeLosAvailable, nativeLosAvailable)
	glUniform(fogUniforms.unitDepthAvailable, unitAvailable)
	glUniform(fogUniforms.featureDepthAvailable, featureAvailable)
	return true
end

local function EndFogShader()
	glUseShader(0)
	glTexture(5, false)
	glTexture(4, false)
	glTexture(3, false)
	glTexture(2, false)
	glTexture(1, false)
	glTexture(0, false)
end

local function DrawFullscreenFogQuad()
	DrawClipSpaceQuad()
end

local function DrawCustomFog()
	if not visionMaskReady or visionMaskFailed or not visionMaskHasData or not exploredMaskReady or not exploredMaskHasData or not fogShaderReady then
		return
	end

	glDepthTest(false)
	glDepthMask(false)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	glColor(1, 1, 1, 1)

	if BeginFogShader() then
		DrawFullscreenFogQuad()
		EndFogShader()
	end

	glColor(1, 1, 1, 1)
	glDepthMask(true)
	glDepthTest(false)
end

--------------------------------------------------------------------------------
-- Selected-Mech AR HUD
--------------------------------------------------------------------------------

local function VertexWithHexTex(x, y, z)
	glTexCoord(x / HEX_PATTERN_SIZE, z / HEX_PATTERN_SIZE)
	glVertex(x, y, z)
end

local function DrawCircularHexOverlay(cx, cz, radius, alphaScale)
	if not HEX_TEXTURE or HEX_PATTERN_ALPHA <= 0 then
		return
	end

	glTexture(HEX_TEXTURE)
	glBlending(GL.SRC_ALPHA, GL.ONE)

	for radial = 0, SECTOR_RADIAL_SEGMENTS - 1 do
		local r0t = radial / SECTOR_RADIAL_SEGMENTS
		local r1t = (radial + 1) / SECTOR_RADIAL_SEGMENTS
		local r0 = radius * r0t
		local r1 = radius * r1t
		local a0 = HEX_PATTERN_ALPHA * (0.35 + 0.65 * r0t) * alphaScale
		local a1 = HEX_PATTERN_ALPHA * (0.35 + 0.65 * r1t) * alphaScale

		glBeginEnd(GL.TRIANGLE_STRIP, function()
			for i = 0, FULL_CIRCLE_SEGMENTS do
				local angle = TWO_PI * (i / FULL_CIRCLE_SEGMENTS)
				local x0, y0, z0 = GroundVertex(cx, cz, angle, r0)
				local x1, y1, z1 = GroundVertex(cx, cz, angle, r1)

				glColor(SIGHT_COLOR[1], SIGHT_COLOR[2], SIGHT_COLOR[3], a0)
				VertexWithHexTex(x0, y0, z0)
				glColor(SIGHT_COLOR[1], SIGHT_COLOR[2], SIGHT_COLOR[3], a1)
				VertexWithHexTex(x1, y1, z1)
			end
		end)
	end

	glTexture(false)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
end

local function DrawSectorHexOverlay(cx, cz, heading, halfAngle, innerRadius, outerRadius, alphaScale)
	if not HEX_TEXTURE or HEX_PATTERN_ALPHA <= 0 then
		return
	end

	local startAngle = heading - halfAngle
	local fullAngle = halfAngle * 2
	local featherRad = rad(ANGULAR_FILL_FEATHER_DEGREES)

	glTexture(HEX_TEXTURE)
	glBlending(GL.SRC_ALPHA, GL.ONE)

	for radial = 0, SECTOR_RADIAL_SEGMENTS - 1 do
		local r0t = radial / SECTOR_RADIAL_SEGMENTS
		local r1t = (radial + 1) / SECTOR_RADIAL_SEGMENTS
		local r0 = innerRadius + (outerRadius - innerRadius) * r0t
		local r1 = innerRadius + (outerRadius - innerRadius) * r1t
		local ringFade0 = 1.0 - (r0t * 0.45)
		local ringFade1 = 1.0 - (r1t * 0.45)

		glBeginEnd(GL.TRIANGLE_STRIP, function()
			for i = 0, SECTOR_ARC_SEGMENTS do
				local t = i / SECTOR_ARC_SEGMENTS
				local angle = startAngle + fullAngle * t
				local edgeDistance = min(fullAngle * t, fullAngle * (1 - t))
				local edgeFade = Clamp01(edgeDistance / max(featherRad, 0.0001))
				local x0, y0, z0 = GroundVertex(cx, cz, angle, r0)
				local x1, y1, z1 = GroundVertex(cx, cz, angle, r1)

				glColor(SECTOR_COLOR[1], SECTOR_COLOR[2], SECTOR_COLOR[3], HEX_PATTERN_ALPHA * ringFade0 * edgeFade * alphaScale)
				VertexWithHexTex(x0, y0, z0)
				glColor(SECTOR_COLOR[1], SECTOR_COLOR[2], SECTOR_COLOR[3], HEX_PATTERN_ALPHA * ringFade1 * edgeFade * alphaScale)
				VertexWithHexTex(x1, y1, z1)
			end
		end)
	end

	glTexture(false)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
end

local function DrawArcLine(cx, cz, radius, startAngle, endAngle, segments, color, alpha, width)
	glColor(color[1], color[2], color[3], alpha)
	glLineWidth(width)

	glBeginEnd(GL.LINE_STRIP, function()
		for i = 0, segments do
			local t = i / segments
			local angle = startAngle + (endAngle - startAngle) * t
			local x, y, z = GroundVertex(cx, cz, angle, radius)
			glVertex(x, y, z)
		end
	end)
end

local function DrawRadialLine(cx, cz, angle, innerRadius, outerRadius, segments, color, alpha, width)
	glColor(color[1], color[2], color[3], alpha)
	glLineWidth(width)

	glBeginEnd(GL.LINE_STRIP, function()
		for i = 0, segments do
			local t = i / segments
			local radius = innerRadius + (outerRadius - innerRadius) * t
			local x, y, z = GroundVertex(cx, cz, angle, radius)
			glVertex(x, y, z)
		end
	end)
end

local function DrawArcGlow(cx, cz, radius, startAngle, endAngle, segments, color, alpha)
	local innerRadius = max(0, radius - GLOW_WIDTH)
	local outerRadius = radius + GLOW_WIDTH

	glBeginEnd(GL.TRIANGLE_STRIP, function()
		for i = 0, segments do
			local t = i / segments
			local angle = startAngle + (endAngle - startAngle) * t
			local x1, y1, z1 = GroundVertex(cx, cz, angle, innerRadius)
			local x2, y2, z2 = GroundVertex(cx, cz, angle, radius)

			glColor(color[1], color[2], color[3], 0)
			glVertex(x1, y1, z1)
			glColor(color[1], color[2], color[3], alpha)
			glVertex(x2, y2, z2)
		end
	end)

	glBeginEnd(GL.TRIANGLE_STRIP, function()
		for i = 0, segments do
			local t = i / segments
			local angle = startAngle + (endAngle - startAngle) * t
			local x2, y2, z2 = GroundVertex(cx, cz, angle, radius)
			local x3, y3, z3 = GroundVertex(cx, cz, angle, outerRadius)

			glColor(color[1], color[2], color[3], alpha)
			glVertex(x2, y2, z2)
			glColor(color[1], color[2], color[3], 0)
			glVertex(x3, y3, z3)
		end
	end)
end

local function DrawSelectedSector(unitID, unitDefID, halfAngle, sectorRange)
	local cx, cz, heading = ResolveCockpitPose(unitID, unitDefID)
	if not cx then
		return
	end

	sectorRange = max(LOS + 1, sectorRange)
	local unitY = spGetGroundHeight(cx, cz)
	local alphaScale = GetZoomAlphaScale(cx, unitY, cz)
	local startAngle = heading - halfAngle
	local endAngle = heading + halfAngle

	DrawCircularHexOverlay(cx, cz, LOS, alphaScale)
	DrawSectorHexOverlay(cx, cz, heading, halfAngle, LOS, sectorRange, alphaScale)

	DrawArcGlow(cx, cz, LOS, 0, TWO_PI, FULL_CIRCLE_SEGMENTS, SIGHT_COLOR, GLOW_ALPHA * alphaScale)
	DrawArcLine(cx, cz, LOS, 0, TWO_PI, FULL_CIRCLE_SEGMENTS, SIGHT_COLOR, SIGHT_RING_ALPHA * alphaScale, CORE_LINE_WIDTH)

	DrawArcGlow(cx, cz, sectorRange, startAngle, endAngle, SECTOR_ARC_SEGMENTS, SECTOR_COLOR, GLOW_ALPHA * alphaScale)
	DrawArcLine(cx, cz, sectorRange, startAngle, endAngle, SECTOR_ARC_SEGMENTS, SECTOR_COLOR, OUTER_ARC_ALPHA * alphaScale, CORE_LINE_WIDTH)

	DrawRadialLine(cx, cz, startAngle, LOS, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, GLOW_ALPHA * alphaScale, GLOW_LINE_WIDTH)
	DrawRadialLine(cx, cz, endAngle, LOS, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, GLOW_ALPHA * alphaScale, GLOW_LINE_WIDTH)
	DrawRadialLine(cx, cz, startAngle, LOS, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, SECTOR_EDGE_ALPHA * alphaScale, CORE_LINE_WIDTH)
	DrawRadialLine(cx, cz, endAngle, LOS, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, SECTOR_EDGE_ALPHA * alphaScale, CORE_LINE_WIDTH)

	if DRAW_TARGETING_RAILS then
		local railOffset = rad(TARGETING_RAIL_OFFSET_DEGREES)
		DrawRadialLine(cx, cz, startAngle, 0, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, TARGETING_RAIL_ALPHA * 0.90 * alphaScale, TARGETING_RAIL_WIDTH)
		DrawRadialLine(cx, cz, endAngle, 0, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, TARGETING_RAIL_ALPHA * 0.90 * alphaScale, TARGETING_RAIL_WIDTH)
		DrawRadialLine(cx, cz, heading - railOffset, 0, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, TARGETING_RAIL_ALPHA * alphaScale, TARGETING_RAIL_WIDTH)
		DrawRadialLine(cx, cz, heading + railOffset, 0, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, TARGETING_RAIL_ALPHA * alphaScale, TARGETING_RAIL_WIDTH)
	end

	if DRAW_CENTERLINE then
		glLineStipple(2, 0xAAAA)
		DrawRadialLine(cx, cz, heading, 0, sectorRange, SIDE_LINE_SEGMENTS, SECTOR_COLOR, CENTERLINE_ALPHA * alphaScale, 1.0)
		glLineStipple(false)
	end

	if DRAW_MID_GUIDE_ARC then
		local guideRadius = LOS + (sectorRange - LOS) * 0.5
		DrawArcLine(cx, cz, guideRadius, startAngle, endAngle, SECTOR_ARC_SEGMENTS, SECTOR_COLOR, GUIDE_ARC_ALPHA * alphaScale, 1.0)
	end
end

--------------------------------------------------------------------------------
-- Selected-unit radar HUD
--------------------------------------------------------------------------------

-- Radar helpers live on RADAR_STYLE rather than consuming additional top-level
-- locals. The union boundary of circles is made from the portions of each
-- circle circumference that are not contained inside any other selected radar
-- circle. This removes all internal/intersecting ring lines without affecting
-- engine radar or the FOW masks.

function RADAR_STYLE.GetLiveRadius(unitID, unitDefID)
	local radius = nil

	if Spring.GetUnitSensorRadius then
		radius = Spring.GetUnitSensorRadius(unitID, "radar")
	end

	if radius == nil then
		local unitDef = unitDefID and UnitDefs[unitDefID]
		radius = unitDef and unitDef.radarDistance or 0
	end

	return tonumber(radius) or 0
end

function RADAR_STYLE.BuildSources(selectedUnitsSorted)
	local sources = {}

	for unitDefID, units in pairs(selectedUnitsSorted) do
		for i = 1, #units do
			local unitID = units[i]

			if spGetUnitDefID(unitID) == unitDefID then
				local transported = spGetUnitTransporter and spGetUnitTransporter(unitID)
				local active = not Spring.GetUnitIsActive or Spring.GetUnitIsActive(unitID)

				if not transported and active then
					local radius = RADAR_STYLE.GetLiveRadius(unitID, unitDefID)
					if radius > 0 then
						local x, y, z = spGetUnitPosition(unitID)
						if x then
							local groundY = spGetGroundHeight(x, z)
							sources[#sources + 1] = {
								unitID = unitID,
								x = x,
								z = z,
								radius = radius,
								alphaScale = GetZoomAlphaScale(x, groundY, z),
							}
						end
					end
				end
			end
		end
	end

	return sources
end

function RADAR_STYLE.GetExposedArcs(sourceIndex, sources)
	local source = sources[sourceIndex]
	local covered = {}
	local epsilon = 0.001

	for otherIndex = 1, #sources do
		if otherIndex ~= sourceIndex then
			local other = sources[otherIndex]
			local dx = other.x - source.x
			local dz = other.z - source.z
			local d2 = dx * dx + dz * dz
			local d = sqrt(d2)

			-- Coincident circles need one deterministic owner or both would hide
			-- each other's entire boundary.
			if d <= epsilon then
				if other.radius > source.radius + epsilon then
					return {}
				elseif math.abs(other.radius - source.radius) <= epsilon and otherIndex < sourceIndex then
					return {}
				end
			elseif d + source.radius <= other.radius + epsilon then
				-- This radar circle is completely contained by another.
				return {}
			elseif d < source.radius + other.radius - epsilon and d + other.radius > source.radius + epsilon then
				-- Partial overlap. Find the angular interval of this circle's
				-- circumference that lies inside the other circle.
				local c = (source.radius * source.radius + d2 - other.radius * other.radius) / (2 * source.radius * d)
				c = max(-1, min(1, c))
				local half = math.acos(c)
				local center = math.atan2(dx, dz)

				while center < 0 do
					center = center + TWO_PI
				end
				while center >= TWO_PI do
					center = center - TWO_PI
				end

				local a0 = center - half
				local a1 = center + half

				if a0 < 0 then
					covered[#covered + 1] = {0, a1}
					covered[#covered + 1] = {a0 + TWO_PI, TWO_PI}
				elseif a1 > TWO_PI then
					covered[#covered + 1] = {a0, TWO_PI}
					covered[#covered + 1] = {0, a1 - TWO_PI}
				else
					covered[#covered + 1] = {a0, a1}
				end
			end
		end
	end

	if #covered == 0 then
		return {{0, TWO_PI}}
	end

	table.sort(covered, function(a, b)
		return a[1] < b[1]
	end)

	local merged = {}
	for i = 1, #covered do
		local interval = covered[i]
		local last = merged[#merged]
		if last and interval[1] <= last[2] + epsilon then
			last[2] = max(last[2], interval[2])
		else
			merged[#merged + 1] = {interval[1], interval[2]}
		end
	end

	local exposed = {}
	local cursor = 0
	for i = 1, #merged do
		local interval = merged[i]
		if interval[1] > cursor + epsilon then
			exposed[#exposed + 1] = {cursor, interval[1]}
		end
		cursor = max(cursor, interval[2])
	end

	if cursor < TWO_PI - epsilon then
		exposed[#exposed + 1] = {cursor, TWO_PI}
	end

	return exposed
end

function RADAR_STYLE.DrawDiffuseArc(source, startAngle, endAngle)
	local innerRadius = max(0, source.radius - RADAR_STYLE.diffuseWidth)
	local span = max(1, source.radius - innerRadius)
	local arcSegments = max(2, math.ceil(RADAR_STYLE.ringSegments * ((endAngle - startAngle) / TWO_PI)))

	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	for radial = 0, RADAR_STYLE.radialSteps - 1 do
		local t0 = radial / RADAR_STYLE.radialSteps
		local t1 = (radial + 1) / RADAR_STYLE.radialSteps
		local r0 = innerRadius + span * t0
		local r1 = innerRadius + span * t1
		local a0 = (RADAR_STYLE.diffuseInnerAlpha + (RADAR_STYLE.diffuseEdgeAlpha - RADAR_STYLE.diffuseInnerAlpha) * t0) * source.alphaScale
		local a1 = (RADAR_STYLE.diffuseInnerAlpha + (RADAR_STYLE.diffuseEdgeAlpha - RADAR_STYLE.diffuseInnerAlpha) * t1) * source.alphaScale

		glBeginEnd(GL.TRIANGLE_STRIP, function()
			for i = 0, arcSegments do
				local t = i / arcSegments
				local angle = startAngle + (endAngle - startAngle) * t
				local x0, y0, z0 = GroundVertex(source.x, source.z, angle, r0)
				local x1, y1, z1 = GroundVertex(source.x, source.z, angle, r1)

				glColor(RADAR_STYLE.color[1], RADAR_STYLE.color[2], RADAR_STYLE.color[3], a0)
				glVertex(x0, y0, z0)
				glColor(RADAR_STYLE.color[1], RADAR_STYLE.color[2], RADAR_STYLE.color[3], a1)
				glVertex(x1, y1, z1)
			end
		end)
	end
end

function RADAR_STYLE.DrawHexArc(source, startAngle, endAngle)
	if not HEX_TEXTURE or RADAR_STYLE.hexAlpha <= 0 then
		return
	end

	local innerRadius = max(0, source.radius - RADAR_STYLE.diffuseWidth)
	local span = max(1, source.radius - innerRadius)
	local arcSegments = max(2, math.ceil(RADAR_STYLE.ringSegments * ((endAngle - startAngle) / TWO_PI)))

	glTexture(HEX_TEXTURE)
	glBlending(GL.SRC_ALPHA, GL.ONE)

	for radial = 0, RADAR_STYLE.radialSteps - 1 do
		local t0 = radial / RADAR_STYLE.radialSteps
		local t1 = (radial + 1) / RADAR_STYLE.radialSteps
		local r0 = innerRadius + span * t0
		local r1 = innerRadius + span * t1
		local a0 = RADAR_STYLE.hexAlpha * t0 * source.alphaScale
		local a1 = RADAR_STYLE.hexAlpha * t1 * source.alphaScale

		glBeginEnd(GL.TRIANGLE_STRIP, function()
			for i = 0, arcSegments do
				local t = i / arcSegments
				local angle = startAngle + (endAngle - startAngle) * t
				local x0, y0, z0 = GroundVertex(source.x, source.z, angle, r0)
				local x1, y1, z1 = GroundVertex(source.x, source.z, angle, r1)

				glColor(RADAR_STYLE.color[1], RADAR_STYLE.color[2], RADAR_STYLE.color[3], a0)
				glTexCoord(x0 / RADAR_STYLE.hexSize, z0 / RADAR_STYLE.hexSize)
				glVertex(x0, y0, z0)
				glColor(RADAR_STYLE.color[1], RADAR_STYLE.color[2], RADAR_STYLE.color[3], a1)
				glTexCoord(x1 / RADAR_STYLE.hexSize, z1 / RADAR_STYLE.hexSize)
				glVertex(x1, y1, z1)
			end
		end)
	end

	glTexture(false)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
end

function RADAR_STYLE.DrawUnion(selectedUnitsSorted)
	if not RADAR_STYLE.draw then
		return
	end

	local sources = RADAR_STYLE.BuildSources(selectedUnitsSorted)
	if #sources == 0 then
		return
	end

	for sourceIndex = 1, #sources do
		local source = sources[sourceIndex]
		local arcs = RADAR_STYLE.GetExposedArcs(sourceIndex, sources)

		for arcIndex = 1, #arcs do
			local arc = arcs[arcIndex]
			local startAngle = arc[1]
			local endAngle = arc[2]

			RADAR_STYLE.DrawDiffuseArc(source, startAngle, endAngle)
			RADAR_STYLE.DrawHexArc(source, startAngle, endAngle)
			DrawArcGlow(
				source.x,
				source.z,
				source.radius,
				startAngle,
				endAngle,
				max(2, math.ceil(RADAR_STYLE.ringSegments * ((endAngle - startAngle) / TWO_PI))),
				RADAR_STYLE.color,
				RADAR_STYLE.glowAlpha * source.alphaScale
			)
			DrawArcLine(
				source.x,
				source.z,
				source.radius,
				startAngle,
				endAngle,
				max(2, math.ceil(RADAR_STYLE.ringSegments * ((endAngle - startAngle) / TWO_PI))),
				RADAR_STYLE.color,
				RADAR_STYLE.ringAlpha * source.alphaScale,
				RADAR_STYLE.ringWidth
			)
		end
	end
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function widget:Initialize()
	local inUse = false
	for unitDefID, unitDef in ipairs(UnitDefs) do
		local halfAngle = GetUnitDefHalfAngle(unitDef)
		if halfAngle then
			unitDefInfos[unitDefID] = {
				halfAngle = halfAngle,
			}
			inUse = true
		end
	end

	if spGetMapDrawMode then
		engineLosWasActive = (spGetMapDrawMode() == "los")
	end
	SuppressNativeLosOverlay()

	RefreshAlliedMechs(true)

	if not InitializeVisionMaskTexture() then
		Spring.Echo("[MCL FOW r13] Custom FOW disabled because the visibility mask could not be created.")
		return
	end

	if not InitializeExploredMaskTextures() then
		Spring.Echo("[MCL FOW r13] Custom FOW disabled because the explored-memory textures could not be created.")
		return
	end

	if not InitializeExploredUpdateShader() then
		Spring.Echo("[MCL FOW r13] Custom FOW disabled because the explored-memory update shader could not be created.")
		return
	end

	InitializeModelDepthCaptureTextures()
	InitializeDepthCopyShader()

	if not InitializeFogShader() then
		Spring.Echo("[MCL FOW r13] Custom FOW disabled because the fog shader could not be created.")
		return
	end

	if not ValidateScreenFogRenderer() then
		Spring.Echo("[MCL FOW r13] Custom FOW disabled because screen-space depth fog rendering is unavailable.")
		return
	end

	Spring.Echo("[MCL FOW r13] Native LOS overlay suppressed; custom MCL FOW is authoritative for map presentation.")
	Spring.Echo("[MCL FOW r13] Current visibility = native LOS union unified Mech close-sight/sector masks; explored memory starts blank each game.")
	Spring.Echo("[MCL FOW r13] Selected friendly radar circles use a merged exterior boundary with inward diffuse/hex treatment; radar visualization does not affect FOW.")
end

function widget:Shutdown()
	if fogShader and glDeleteShader then
		glDeleteShader(fogShader)
	end
	fogShader = nil
	fogShaderReady = false
	fogUniforms = {}

	if exploredUpdateShader and glDeleteShader then
		glDeleteShader(exploredUpdateShader)
	end
	exploredUpdateShader = nil
	exploredUpdateShaderReady = false
	exploredUpdateUniforms = {}

	if depthCopyShader and glDeleteShader then
		glDeleteShader(depthCopyShader)
	end
	depthCopyShader = nil
	depthCopyShaderReady = false
	DeleteModelDepthCaptureTextures()

	if visionMaskTexture and glDeleteTexture then
		glDeleteTexture(visionMaskTexture)
	end
	visionMaskTexture = nil
	visionMaskReady = false
	visionMaskHasData = false

	for i = 1, 2 do
		if exploredMaskTextures[i] and glDeleteTexture then
			glDeleteTexture(exploredMaskTextures[i])
		end
		exploredMaskTextures[i] = nil
	end
	exploredMaskReady = false
	exploredMaskHasData = false

	-- Restore native LOS only when it was active before this widget took over,
	-- and only if the user is currently in ordinary map mode.
	if engineLosWasActive and spGetMapDrawMode and spSendCommands and spGetMapDrawMode() == "normal" then
		spSendCommands("showlos")
	end
end

function widget:Update(dt)
	engineLosCheckAccumulator = engineLosCheckAccumulator + (dt or 0)
	if engineLosCheckAccumulator >= ENGINE_LOS_CHECK_INTERVAL then
		engineLosCheckAccumulator = 0
		SuppressNativeLosOverlay()
	end
end

function widget:ViewResize()
	if unitDepthTexture or featureDepthTexture then
		InitializeModelDepthCaptureTextures()
	end
end

function widget:UnitCreated()
	lastAlliedRefreshFrame = -999999
end

function widget:UnitDestroyed()
	lastAlliedRefreshFrame = -999999
end

function widget:UnitGiven()
	lastAlliedRefreshFrame = -999999
end

function widget:UnitTaken()
	lastAlliedRefreshFrame = -999999
end

--------------------------------------------------------------------------------
-- Draw call-ins
--------------------------------------------------------------------------------

function widget:DrawGenesis()
	-- Recoil restricts OpenGL work such as gl.RenderToTexture() to Draw call-ins.
	-- DrawGenesis is explicitly intended for updating textures/shaders without
	-- rendering anything to the screen, so the persistent vision mask is built here.
	if visionMaskReady and not visionMaskFailed then
		if UpdateVisionMask() then
			UpdateExploredMask()
		end
	end

	if unitDepthTexture or featureDepthTexture then
		ClearModelDepthCaptures()
	end
end

function widget:DrawWorldPreUnit()
	-- Intentionally empty in r13. Fog is composited after opaque units/features
	-- so model antialiasing is resolved before darkness is applied.
end

function widget:DrawUnitsPostDeferred()
	if unitDepthTexture and depthCopyShaderReady then
		unitDepthHasData = CaptureCurrentModelDepth(unitDepthTexture)
	end
end

function widget:DrawFeaturesPostDeferred()
	if featureDepthTexture and depthCopyShaderReady then
		featureDepthHasData = CaptureCurrentModelDepth(featureDepthTexture)
	end
end

function widget:DrawWorld()
	-- One final fog pass covers the already-rendered opaque world. This avoids
	-- dark halos caused by antialiased model edges blending over pre-darkened ground.
	DrawCustomFog()

	if not DRAW_SELECTED_AR_HUD and not RADAR_STYLE.draw then
		return
	end

	if spIsGUIHidden and spIsGUIHidden() then
		return
	end

	local selectedUnitsSorted = spGetSelectedUnitsSorted()
	if not selectedUnitsSorted then
		return
	end

	glDepthTest(true)
	glDepthMask(false)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	if RADAR_STYLE.draw then
		RADAR_STYLE.DrawUnion(selectedUnitsSorted)
	end

	if DRAW_SELECTED_AR_HUD then
		for unitDefID, info in pairs(unitDefInfos) do
		local units = selectedUnitsSorted[unitDefID]
		if units then
			for i = 1, #units do
				local unitID = units[i]
				if spGetUnitDefID(unitID) then
					local transporterID = spGetUnitTransporter and spGetUnitTransporter(unitID)
					if not transporterID then
						local sectorRange = (spGetUnitRulesParam(unitID, "sectorradius") or RADAR) - SECTOR_RANGE_INSET
						DrawSelectedSector(unitID, unitDefID, info.halfAngle, sectorRange)
					end
				end
			end
		end
	end
	end

	glLineStipple(false)
	glLineWidth(1)
	glTexture(false)
	glColor(1, 1, 1, 1)
	glBlending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	glDepthMask(true)
	glDepthTest(false)
end
