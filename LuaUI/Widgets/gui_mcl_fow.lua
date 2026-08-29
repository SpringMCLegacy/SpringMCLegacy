function widget:GetInfo()
	return {
		name = "MC:L - Custom Fog of War r27",
		desc = "Custom MCL visual fog-of-war with allyteam-aware Unexplored / Explored / Visible presentation, spectator isolation, organic exploration boundaries, and synchronized minimap presentation",
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

-- Visual-only organic treatment for the Unexplored <-> Explored frontier.
-- The stored explored mask is never modified: only the final shader samples it
-- through a small deterministic world-space warp. Visible LOS/sector edges are
-- deliberately left exact.
local FOW_BOUNDARY_STYLE = {
	enabled = true,
	noiseScale = 180,
	warpWorld = 18,
	detailWeight = 0.35,
}

-- Mask edge smoothing. The raw union mask is linearly filtered and then passed
-- through smoothstep(EDGE_LOW, EDGE_HIGH). A wider interval gives a softer edge.
local FOG_EDGE_LOW = 0.08
local FOG_EDGE_HIGH = 0.92
local FOG_EDGE_SAMPLE_RADIUS = 1.50

-- Map-space visibility mask.
local VISION_MASK_MAX_DIM = 1024
local VISION_MASK_MIN_DIM = 256
local VISION_MASK_UPDATE_FRAMES = 1
local EXPLORED_MASK_UPDATE_FRAMES = 1
local ALLIED_MECH_REFRESH_FRAMES = 60

-- The custom Mech mask is written with continuous sub-texel coverage instead
-- of a hard binary polygon edge. This feather is measured in mask texels so
-- its apparent smoothness remains consistent across different map sizes.
local MASK_COVERAGE_FEATHER_TEXELS = 3.0

-- Visual terrain occlusion for the custom Mech mask. The GPU samples Recoil's
-- live $heightmap along the sightline from the cockpit to each candidate terrain
-- point. This affects presentation only; engine LOS/gameplay remains unchanged.
local TERRAIN_VISIBILITY = {
	enabled = true,
	sampleSpacing = 32,
	clearance = 3,
	softness = 4,
	targetLift = 2,
}

-- Fog compositing is screen-space. The map's g-buffer depth is used to
-- reconstruct the terrain world position for each visible pixel, so there is no
-- second ground surface to z-fight with and no terrain-sized geometry cost.
local MAP_DEPTH_TEXTURE = "$map_gbuffer_zvaltex"
local MODEL_DEPTH_TEXTURE = "$model_gbuffer_zvaltex"
local NATIVE_LOS_TEXTURE = "$info:los"

-- MCL vision geometry. Mech close sight and directional sight are rasterized
-- into the same custom mask so there is no independently filtered join between
-- the close circle and forward sector. Native LOS remains gameplay/exploration
-- data only and is intentionally excluded from the final Visible presentation.
local SECTOR_RANGE_INSET = 50

-- Minimap presentation mirrors the actual custom FOW state without changing
-- any FOW logic. The three-state minimap overlay is pre-rendered from the same
-- visibility/exploration textures during DrawGenesis(), then composited over
-- the engine minimap terrain background as a simple texture.
local MINIMAP_STYLE = {
	drawFog = true,
	fogShader = nil,
	fogShaderReady = false,
	uniforms = {},
	fogTexture = nil,
	fogTextureReady = false,
	fogTextureHasData = false,
	loggedFirstFogTextureUpdate = false,
	loggedFirstForegroundDraw = false,
	lastFogTextureFrame = -999999,
	updateFrames = 1,
}


-- Keep the native LOS overlay suppressed if the player presses the normal LOS
-- key while this widget owns FOW presentation.
local ENGINE_LOS_CHECK_INTERVAL = 0.20

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local unitDefInfos = {}
local cockpitPieceCache = {}
local alliedMechs = {}
local alliedCircularLosSources = {}
local lastAlliedRefreshFrame = -999999

local visionMaskTexture = nil
local visionMaskWidth = 0
local visionMaskHeight = 0
local visionMaskReady = false
local visionMaskFailed = false
local visionMaskHasData = false
local lastVisionMaskDrawFrame = -999999
local loggedFirstMaskUpdate = false
local visionMaskCoverageShader = nil
local visionMaskCoverageShaderReady = false
local visionMaskCoverageUniforms = {}
local visionMaskCoverageFeatherWorld = 1.0

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

-- Perspective state is centralized here so ordinary players, team games and
-- spectators all use an explicit allyteam point of view. Explored history is
-- kept separately per allyteam during this widget/game-session lifetime.
local VIEW_STATE = {
	spectating = false,
	fullView = false,
	fullSelect = false,
	teamID = nil,
	allyTeamID = nil,
	fowEnabled = true,
	activeExploredKey = nil,
	exploredBanks = {},
}

--------------------------------------------------------------------------------
-- Math helpers
--------------------------------------------------------------------------------



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
uniform float organicEdgeEnabled;
uniform float organicEdgeScale;
uniform float organicEdgeWarp;
uniform float organicEdgeDetailWeight;

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

float hash21(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float valueNoise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec2 getOrganicExploredUV(vec2 mapUV, vec2 worldXZ)
{
	if (organicEdgeEnabled < 0.5 || organicEdgeWarp <= 0.0) {
		return mapUV;
	}

	float scale = max(organicEdgeScale, 1.0);
	vec2 coarse = vec2(
		valueNoise(worldXZ / scale),
		valueNoise((worldXZ + vec2(913.7, -421.3)) / scale)
	) * 2.0 - 1.0;

	vec2 detail = vec2(
		valueNoise((worldXZ + vec2(211.9, 617.3)) / (scale * 0.37)),
		valueNoise((worldXZ + vec2(-733.1, 149.5)) / (scale * 0.37))
	) * 2.0 - 1.0;

	float detailWeight = max(0.0, organicEdgeDetailWeight);
	vec2 offsetWorld = (coarse + detail * detailWeight) / (1.0 + detailWeight);
	offsetWorld *= organicEdgeWarp;

	return clamp(mapUV + offsetWorld / max(mapSize, vec2(1.0)), 0.0, 1.0);
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
	vec2 exploredUV = getOrganicExploredUV(mapUV, worldPos.xz);
	float exploredVisibility = max(texture2D(exploredMaskTex, exploredUV).r, currentVisibility);

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
uniform vec2 mapSize;
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
-- Minimap FOW shader
--------------------------------------------------------------------------------

MINIMAP_STYLE.vertexShader = [[
#version 130

varying vec2 vMapUV;

void main()
{
	vMapUV = gl_MultiTexCoord0.st;
	gl_Position = gl_Vertex;
}
]]

MINIMAP_STYLE.fragmentShader = [[
#version 130

uniform sampler2D sectorMaskTex;
uniform sampler2D exploredMaskTex;
uniform sampler2D nativeLosTex;
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
uniform float organicEdgeEnabled;
uniform float organicEdgeScale;
uniform float organicEdgeWarp;
uniform float organicEdgeDetailWeight;

varying vec2 vMapUV;

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

float hash21(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float valueNoise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec2 getOrganicExploredUV(vec2 mapUV)
{
	if (organicEdgeEnabled < 0.5 || organicEdgeWarp <= 0.0) {
		return mapUV;
	}

	vec2 worldXZ = mapUV * mapSize;
	float scale = max(organicEdgeScale, 1.0);
	vec2 coarse = vec2(
		valueNoise(worldXZ / scale),
		valueNoise((worldXZ + vec2(913.7, -421.3)) / scale)
	) * 2.0 - 1.0;
	vec2 detail = vec2(
		valueNoise((worldXZ + vec2(211.9, 617.3)) / (scale * 0.37)),
		valueNoise((worldXZ + vec2(-733.1, 149.5)) / (scale * 0.37))
	) * 2.0 - 1.0;
	float detailWeight = max(0.0, organicEdgeDetailWeight);
	vec2 offsetWorld = (coarse + detail * detailWeight) / (1.0 + detailWeight);
	offsetWorld *= organicEdgeWarp;
	return clamp(mapUV + offsetWorld / max(mapSize, vec2(1.0)), 0.0, 1.0);
}

void main()
{
	vec2 mapUV = clamp(vMapUV, 0.0, 1.0);
	float sectorVisibility = getSectorVisibility(mapUV);
	float nativeVisibility = getNativeVisibility(mapUV);
	float currentVisibility = max(sectorVisibility, nativeVisibility);
	vec2 exploredUV = getOrganicExploredUV(mapUV);
	float exploredVisibility = max(texture2D(exploredMaskTex, exploredUV).r, currentVisibility);

	float alpha = mix(unexploredFogAlpha, exploredFogAlpha, exploredVisibility);
	alpha = mix(alpha, visibleFogAlpha, currentVisibility);

	if (alpha <= 0.001) {
		discard;
	}

	gl_FragColor = vec4(fogColor, alpha);
}
]]

function MINIMAP_STYLE.InitializeFogShader()
	if not gl.CreateShader or not gl.UseShader or not gl.GetUniformLocation or not gl.Uniform then
		return false
	end

	MINIMAP_STYLE.fogShader = gl.CreateShader({
		vertex = MINIMAP_STYLE.vertexShader,
		fragment = MINIMAP_STYLE.fragmentShader,
		uniformInt = {
			sectorMaskTex = 0,
			exploredMaskTex = 1,
			nativeLosTex = 2,
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
			organicEdgeEnabled = FOW_BOUNDARY_STYLE.enabled and 1.0 or 0.0,
			organicEdgeScale = FOW_BOUNDARY_STYLE.noiseScale,
			organicEdgeWarp = FOW_BOUNDARY_STYLE.warpWorld,
			organicEdgeDetailWeight = FOW_BOUNDARY_STYLE.detailWeight,
		},
	})

	if not MINIMAP_STYLE.fogShader then
		Spring.Echo("[MCL FOW r27] WARNING: minimap FOW shader failed to compile; world FOW remains active.")
		if gl.GetShaderLog then
			local log = gl.GetShaderLog()
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
		"organicEdgeEnabled",
		"organicEdgeScale",
		"organicEdgeWarp",
		"organicEdgeDetailWeight",
	}

	for i = 1, #names do
		local name = names[i]
		local location = gl.GetUniformLocation(MINIMAP_STYLE.fogShader, name)
		if type(location) ~= "number" or location < 0 then
			Spring.Echo("[MCL FOW r27] WARNING: missing minimap FOW shader uniform " .. name .. "; minimap FOW disabled.")
			if gl.DeleteShader then
				gl.DeleteShader(MINIMAP_STYLE.fogShader)
			end
			MINIMAP_STYLE.fogShader = nil
			MINIMAP_STYLE.uniforms = {}
			return false
		end
		MINIMAP_STYLE.uniforms[name] = location
	end

	MINIMAP_STYLE.fogShaderReady = true
	Spring.Echo("[MCL FOW r27] Minimap FOW texture compositor active; it consumes the existing visibility/exploration masks without changing them.")
	Spring.Echo("[MCL FOW r27] Minimap FOW will composite in DrawInMiniMap after engine minimap content.")
	return true
end

function MINIMAP_STYLE.InitializeFogTexture()
	if not gl.CreateTexture or not visionMaskReady then
		return false
	end

	if MINIMAP_STYLE.fogTexture and gl.DeleteTexture then
		gl.DeleteTexture(MINIMAP_STYLE.fogTexture)
	end
	MINIMAP_STYLE.fogTexture = nil
	MINIMAP_STYLE.fogTextureReady = false
	MINIMAP_STYLE.fogTextureHasData = false

	local ok, texture = pcall(
		gl.CreateTexture,
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
		Spring.Echo("[MCL FOW r27] WARNING: could not create minimap FOW texture; world FOW remains active.")
		return false
	end

	MINIMAP_STYLE.fogTexture = texture
	MINIMAP_STYLE.fogTextureReady = true
	Spring.Echo("[MCL FOW r27] Minimap FOW texture created at " .. visionMaskWidth .. "x" .. visionMaskHeight .. ".")
	return true
end

function MINIMAP_STYLE.RenderFogTextureContents()
	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end

	gl.Viewport(0, 0, visionMaskWidth, visionMaskHeight)
	gl.Clear(GL.COLOR_BUFFER_BIT, 0, 0, 0, 0)
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(false)
	gl.Color(1, 1, 1, 1)

	if not gl.Texture(0, visionMaskTexture) or not gl.Texture(1, exploredMaskTextures[exploredMaskIndex]) then
		gl.Texture(1, false)
		gl.Texture(0, false)
		if gl.PopAttrib then gl.PopAttrib() end
		return false
	end

	local nativeLosAvailable = 0.0
	if gl.Texture(2, NATIVE_LOS_TEXTURE) then
		nativeLosAvailable = 1.0
	else
		gl.Texture(2, false)
	end

	local rendered = false
	if gl.UseShader(MINIMAP_STYLE.fogShader) then
		gl.Uniform(MINIMAP_STYLE.uniforms.mapSize, Game.mapSizeX, Game.mapSizeZ)
		gl.Uniform(MINIMAP_STYLE.uniforms.sectorMaskTexelSize, 1 / visionMaskWidth, 1 / visionMaskHeight)
		gl.Uniform(MINIMAP_STYLE.uniforms.fogColor, FOG_COLOR[1], FOG_COLOR[2], FOG_COLOR[3])
		gl.Uniform(MINIMAP_STYLE.uniforms.unexploredFogAlpha, UNEXPLORED_FOG_ALPHA)
		gl.Uniform(MINIMAP_STYLE.uniforms.exploredFogAlpha, EXPLORED_FOG_ALPHA)
		gl.Uniform(MINIMAP_STYLE.uniforms.visibleFogAlpha, VISIBLE_FOG_ALPHA)
		gl.Uniform(MINIMAP_STYLE.uniforms.edgeLow, FOG_EDGE_LOW)
		gl.Uniform(MINIMAP_STYLE.uniforms.edgeHigh, FOG_EDGE_HIGH)
		gl.Uniform(MINIMAP_STYLE.uniforms.edgeSampleRadius, FOG_EDGE_SAMPLE_RADIUS)
		-- r27 diagnostic: native LOS remains mechanically active and continues to
		-- feed Explored memory, but is excluded from the final minimap Visible edge.
		gl.Uniform(MINIMAP_STYLE.uniforms.nativeLosAvailable, 0.0)
		gl.Uniform(MINIMAP_STYLE.uniforms.organicEdgeEnabled, FOW_BOUNDARY_STYLE.enabled and 1.0 or 0.0)
		gl.Uniform(MINIMAP_STYLE.uniforms.organicEdgeScale, FOW_BOUNDARY_STYLE.noiseScale)
		gl.Uniform(MINIMAP_STYLE.uniforms.organicEdgeWarp, FOW_BOUNDARY_STYLE.warpWorld)
		gl.Uniform(MINIMAP_STYLE.uniforms.organicEdgeDetailWeight, FOW_BOUNDARY_STYLE.detailWeight)

		gl.BeginEnd(GL.QUADS, function()
			gl.TexCoord(0, 0); gl.Vertex(-1, -1, 0, 1)
			gl.TexCoord(1, 0); gl.Vertex( 1, -1, 0, 1)
			gl.TexCoord(1, 1); gl.Vertex( 1,  1, 0, 1)
			gl.TexCoord(0, 1); gl.Vertex(-1,  1, 0, 1)
		end)
		gl.UseShader(0)
		rendered = true
	end

	gl.Texture(2, false)
	gl.Texture(1, false)
	gl.Texture(0, false)
	gl.Color(1, 1, 1, 1)

	if gl.PopAttrib then
		gl.PopAttrib()
	end
	return rendered
end

function MINIMAP_STYLE.UpdateFogTexture()
	if not MINIMAP_STYLE.drawFog or not MINIMAP_STYLE.fogTextureReady or not MINIMAP_STYLE.fogShaderReady or not visionMaskHasData or not exploredMaskHasData then
		return false
	end

	local frame = (Spring.GetGameFrame and Spring.GetGameFrame()) or 0
	if frame - MINIMAP_STYLE.lastFogTextureFrame < MINIMAP_STYLE.updateFrames then
		return true
	end
	MINIMAP_STYLE.lastFogTextureFrame = frame

	local ok, err = pcall(gl.RenderToTexture, MINIMAP_STYLE.fogTexture, MINIMAP_STYLE.RenderFogTextureContents)
	if not ok then
		Spring.Echo("[MCL FOW r27] WARNING: minimap FOW texture update failed: " .. tostring(err))
		MINIMAP_STYLE.fogTextureHasData = false
		return false
	end

	MINIMAP_STYLE.fogTextureHasData = true
	if not MINIMAP_STYLE.loggedFirstFogTextureUpdate then
		MINIMAP_STYLE.loggedFirstFogTextureUpdate = true
		Spring.Echo("[MCL FOW r27] First minimap FOW texture update completed successfully in DrawGenesis().")
	end
	return true
end

function MINIMAP_STYLE.ApplyMapTransform(sx, sy)
	local rotation = Spring.GetMiniMapRotation and Spring.GetMiniMapRotation() or 0
	if math.abs(rotation) > 1.5 then
		gl.Translate(sx, 0, 0)
		gl.Scale(-sx / Game.mapSizeX, sy / Game.mapSizeZ, 1)
	else
		gl.Translate(0, sy, 0)
		gl.Scale(sx / Game.mapSizeX, -sy / Game.mapSizeZ, 1)
	end
end

function MINIMAP_STYLE.DrawFog(sx, sy)
	if not VIEW_STATE.ShouldDrawFog() then
		return
	end
	if not MINIMAP_STYLE.drawFog or not MINIMAP_STYLE.fogTextureReady or not MINIMAP_STYLE.fogTextureHasData then
		return
	end

	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end

	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	gl.Color(1, 1, 1, 1)
	gl.Texture(MINIMAP_STYLE.fogTexture)

	local rotation = Spring.GetMiniMapRotation and Spring.GetMiniMapRotation() or 0
	local quarter = pi * 0.5
	local index = math.floor((rotation / quarter) + 0.5) % 4

	gl.BeginEnd(GL.QUADS, function()
		if index == 1 then
			gl.TexCoord(0, 0); gl.Vertex(0, 0, 0)
			gl.TexCoord(0, 1); gl.Vertex(sx, 0, 0)
			gl.TexCoord(1, 1); gl.Vertex(sx, sy, 0)
			gl.TexCoord(1, 0); gl.Vertex(0, sy, 0)
		elseif index == 2 then
			gl.TexCoord(1, 0); gl.Vertex(0, 0, 0)
			gl.TexCoord(0, 0); gl.Vertex(sx, 0, 0)
			gl.TexCoord(0, 1); gl.Vertex(sx, sy, 0)
			gl.TexCoord(1, 1); gl.Vertex(0, sy, 0)
		elseif index == 3 then
			gl.TexCoord(1, 1); gl.Vertex(0, 0, 0)
			gl.TexCoord(1, 0); gl.Vertex(sx, 0, 0)
			gl.TexCoord(0, 0); gl.Vertex(sx, sy, 0)
			gl.TexCoord(0, 1); gl.Vertex(0, sy, 0)
		else
			gl.TexCoord(0, 1); gl.Vertex(0, 0, 0)
			gl.TexCoord(1, 1); gl.Vertex(sx, 0, 0)
			gl.TexCoord(1, 0); gl.Vertex(sx, sy, 0)
			gl.TexCoord(0, 0); gl.Vertex(0, sy, 0)
		end
	end)

	gl.Texture(false)
	gl.Color(1, 1, 1, 1)

	if gl.PopAttrib then
		gl.PopAttrib()
	end
end

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
		local pieceMap = Spring.GetUnitPieceMap(unitID)
		pieceID = pieceMap and pieceMap["cockpit"] or false
		cockpitPieceCache[unitDefID] = pieceID
	end

	-- GetUnitViewPosition follows Recoil's interpolated render position between
	-- simulation frames. Apply that translation delta to the cockpit piece so the
	-- visual FOW mask follows the Mech smoothly without changing vision geometry.
	local simX, simY, simZ = Spring.GetUnitPosition(unitID)
	if not simX then
		return nil
	end

	local viewX, viewY, viewZ
	if Spring.GetUnitViewPosition then
		viewX, viewY, viewZ = Spring.GetUnitViewPosition(unitID)
	end
	local offsetX = viewX and (viewX - simX) or 0
	local offsetY = viewY and simY and (viewY - simY) or 0
	local offsetZ = viewZ and (viewZ - simZ) or 0

	if pieceID then
		local x, y, z, dx, dy, dz = Spring.GetUnitPiecePosDir(unitID, pieceID)
		if x and y and dx and dz then
			return x + offsetX, y + offsetY, z + offsetZ, math.atan2(dx, dz)
		end
	end

	local heading = Spring.GetUnitHeading(unitID) or 0
	return simX + offsetX, (simY or 0) + offsetY, simZ + offsetZ, heading * HEADING_TO_RAD
end

--------------------------------------------------------------------------------
-- Engine LOS visual suppression
--------------------------------------------------------------------------------

local function SuppressNativeLosOverlay()
	if not Spring.GetMapDrawMode or not Spring.SendCommands then
		return
	end

	if Spring.GetMapDrawMode() == "los" then
		Spring.SendCommands("showstandard")
	end
end

--------------------------------------------------------------------------------
-- Allied visual LOS sources
--------------------------------------------------------------------------------

local function GetLiveLosRadius(unitID, unitDefID)
	local radius = nil
	if Spring.GetUnitSensorRadius then
		radius = tonumber(Spring.GetUnitSensorRadius(unitID, "los"))
	end

	if radius == nil then
		local unitDef = unitDefID and UnitDefs[unitDefID]
		radius = tonumber(unitDef and unitDef.sightDistance) or 0
	end

	return max(0, radius)
end

local function ResolveCircularLosPose(unitID, unitDefID)
	local simX, simY, simZ = Spring.GetUnitPosition(unitID)
	if not simX then
		return nil
	end

	local viewX, viewY, viewZ
	if Spring.GetUnitViewPosition then
		viewX, viewY, viewZ = Spring.GetUnitViewPosition(unitID)
	end

	local offsetX = viewX and (viewX - simX) or 0
	local offsetY = viewY and simY and (viewY - simY) or 0
	local offsetZ = viewZ and (viewZ - simZ) or 0

	local unitDef = unitDefID and UnitDefs[unitDefID]
	local emitHeight = tonumber(unitDef and unitDef.losEmitHeight) or 20

	return simX + offsetX, (simY or 0) + offsetY + emitHeight, simZ + offsetZ
end

local function RefreshAlliedMechs(force)
	local frame = (Spring.GetGameFrame and Spring.GetGameFrame()) or 0
	if not force and frame - lastAlliedRefreshFrame < ALLIED_MECH_REFRESH_FRAMES then
		return
	end

	lastAlliedRefreshFrame = frame
	alliedMechs = {}
	alliedCircularLosSources = {}

	if not Spring.GetTeamList or not Spring.GetTeamUnits then
		return
	end

	local myTeamID = VIEW_STATE.teamID or (Spring.GetMyTeamID and Spring.GetMyTeamID() or nil)
	local teams = Spring.GetTeamList() or {}

	for ti = 1, #teams do
		local teamID = teams[ti]
		local allied = (teamID == myTeamID)

		if not allied and myTeamID and Spring.AreTeamsAllied then
			allied = Spring.AreTeamsAllied(myTeamID, teamID)
		end

		if allied then
			local units = Spring.GetTeamUnits(teamID) or {}
			for ui = 1, #units do
				local unitID = units[ui]
				local unitDefID = Spring.GetUnitDefID(unitID)
				if unitDefID then
					if unitDefInfos[unitDefID] then
						alliedMechs[#alliedMechs + 1] = {
							unitID = unitID,
							unitDefID = unitDefID,
						}
					elseif GetLiveLosRadius(unitID, unitDefID) > 0 then
						-- Non-sector allied units (captured Beacons, structures, vehicles,
						-- etc.) contribute their ordinary live circular engine LOS to the
						-- custom presentation instead of re-enabling native $info:los.
						alliedCircularLosSources[#alliedCircularLosSources + 1] = {
							unitID = unitID,
							unitDefID = unitDefID,
						}
					end
				end
			end
		end
	end
end

local VISION_MASK_COVERAGE_VERTEX_SHADER = [[
#version 130

varying vec2 vWorldXZ;

void main()
{
	vWorldXZ = gl_Vertex.xy;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
]]

local VISION_MASK_COVERAGE_FRAGMENT_SHADER = [[
#version 130

uniform sampler2D heightmapTex;
uniform vec2 mapSize;
uniform vec2 sourceCenter;
uniform vec2 leftBoundaryDir;
uniform vec2 rightBoundaryDir;
uniform float sourceEyeHeight;
uniform float circleRadius;
uniform float sectorRadius;
uniform float sectorEnabled;
uniform float featherWidth;
uniform float terrainEnabled;
uniform float terrainSampleSpacing;
uniform float terrainClearance;
uniform float terrainSoftness;
uniform float terrainTargetLift;

varying vec2 vWorldXZ;

const int MAX_TERRAIN_STEPS = 32;

float cross2D(vec2 a, vec2 b)
{
	return a.x * b.y - a.y * b.x;
}

float sampleTerrainHeight(vec2 worldXZ)
{
	vec2 uv = clamp(worldXZ / max(mapSize, vec2(1.0)), 0.0, 1.0);
	return texture2D(heightmapTex, uv).r;
}

float getTerrainVisibility(vec2 targetXZ, float radialDistance)
{
	if (terrainEnabled < 0.5 || radialDistance <= max(terrainSampleSpacing, 1.0)) {
		return 1.0;
	}

	float targetHeight = sampleTerrainHeight(targetXZ) + terrainTargetLift;
	float requestedSteps = ceil(radialDistance / max(terrainSampleSpacing, 1.0));
	int steps = int(clamp(requestedSteps, 2.0, float(MAX_TERRAIN_STEPS)));
	float maxObstruction = -1000000.0;

	for (int i = 1; i < MAX_TERRAIN_STEPS; ++i) {
		if (i >= steps) {
			break;
		}

		float t = float(i) / float(steps);
		vec2 sampleXZ = mix(sourceCenter, targetXZ, t);
		float terrainHeight = sampleTerrainHeight(sampleXZ);
		float sightlineHeight = mix(sourceEyeHeight, targetHeight, t);
		maxObstruction = max(maxObstruction, terrainHeight - sightlineHeight);
	}

	float softness = max(terrainSoftness, 0.001);
	return 1.0 - smoothstep(terrainClearance - softness, terrainClearance + softness, maxObstruction);
}

void main()
{
	vec2 p = vWorldXZ - sourceCenter;
	float radialDistance = length(p);
	float halfFeather = max(featherWidth * 0.5, 0.001);

	float circleInside = circleRadius - radialDistance;
	float circleCoverage = smoothstep(-halfFeather, halfFeather, circleInside);

	float sectorCoverage = 0.0;
	if (sectorEnabled >= 0.5) {
		float leftInside = -cross2D(leftBoundaryDir, p);
		float rightInside = cross2D(rightBoundaryDir, p);
		float radialInside = sectorRadius - radialDistance;
		float sectorInside = min(radialInside, min(leftInside, rightInside));
		sectorCoverage = smoothstep(-halfFeather, halfFeather, sectorInside);
	}

	float coverage = max(circleCoverage, sectorCoverage);
	if (coverage <= 0.001) {
		discard;
	}

	coverage *= getTerrainVisibility(vWorldXZ, radialDistance);
	if (coverage <= 0.001) {
		discard;
	}

	gl_FragColor = vec4(coverage, coverage, coverage, coverage);
}
]]

local function InitializeVisionMaskCoverageShader()
	if not gl.CreateShader or not gl.UseShader or not gl.GetUniformLocation or not gl.Uniform then
		return false
	end

	visionMaskCoverageShader = gl.CreateShader({
		vertex = VISION_MASK_COVERAGE_VERTEX_SHADER,
		fragment = VISION_MASK_COVERAGE_FRAGMENT_SHADER,
		uniformInt = {
			heightmapTex = 0,
		},
		uniformFloat = {
			mapSize = {Game.mapSizeX, Game.mapSizeZ},
			sourceCenter = {0.0, 0.0},
			leftBoundaryDir = {0.0, 1.0},
			rightBoundaryDir = {0.0, 1.0},
			sourceEyeHeight = 0.0,
			circleRadius = LOS,
			sectorRadius = RADAR,
			sectorEnabled = 1.0,
			featherWidth = visionMaskCoverageFeatherWorld,
			terrainEnabled = TERRAIN_VISIBILITY.enabled and 1.0 or 0.0,
			terrainSampleSpacing = TERRAIN_VISIBILITY.sampleSpacing,
			terrainClearance = TERRAIN_VISIBILITY.clearance,
			terrainSoftness = TERRAIN_VISIBILITY.softness,
			terrainTargetLift = TERRAIN_VISIBILITY.targetLift,
		},
	})

	if not visionMaskCoverageShader then
		Spring.Echo("[MCL FOW r27] ERROR: smooth visibility-mask coverage shader failed to compile.")
		if gl.GetShaderLog then
			local log = gl.GetShaderLog()
			if log and log ~= "" then
				Spring.Echo(log)
			end
		end
		return false
	end

	local names = {
		"mapSize",
		"sourceCenter",
		"leftBoundaryDir",
		"rightBoundaryDir",
		"sourceEyeHeight",
		"circleRadius",
		"sectorRadius",
		"sectorEnabled",
		"featherWidth",
		"terrainEnabled",
		"terrainSampleSpacing",
		"terrainClearance",
		"terrainSoftness",
		"terrainTargetLift",
	}

	for i = 1, #names do
		local name = names[i]
		local location = gl.GetUniformLocation(visionMaskCoverageShader, name)
		if type(location) ~= "number" or location < 0 then
			Spring.Echo("[MCL FOW r27] ERROR: missing smooth visibility-mask shader uniform " .. name .. ".")
			if gl.DeleteShader then
				gl.DeleteShader(visionMaskCoverageShader)
			end
			visionMaskCoverageShader = nil
			visionMaskCoverageUniforms = {}
			return false
		end
		visionMaskCoverageUniforms[name] = location
	end

	visionMaskCoverageShaderReady = true
	Spring.Echo("[MCL FOW r27] Continuous sub-texel terrain-aware visibility-mask coverage active for Mech sectors and allied circular LOS sources.")
	return true
end

local function DrawSmoothMaskSource(cx, cy, cz, circleRadius, heading, halfAngle, sectorRange, sectorEnabled)
	heading = heading or 0
	halfAngle = halfAngle or 0
	sectorRange = sectorRange or 0
	sectorEnabled = sectorEnabled or 0

	local leftAngle = heading - halfAngle
	local rightAngle = heading + halfAngle
	local leftX, leftZ = sin(leftAngle), cos(leftAngle)
	local rightX, rightZ = sin(rightAngle), cos(rightAngle)

	gl.Uniform(visionMaskCoverageUniforms.mapSize, Game.mapSizeX, Game.mapSizeZ)
	gl.Uniform(visionMaskCoverageUniforms.sourceCenter, cx, cz)
	gl.Uniform(visionMaskCoverageUniforms.leftBoundaryDir, leftX, leftZ)
	gl.Uniform(visionMaskCoverageUniforms.rightBoundaryDir, rightX, rightZ)
	gl.Uniform(visionMaskCoverageUniforms.sourceEyeHeight, cy)
	gl.Uniform(visionMaskCoverageUniforms.circleRadius, circleRadius)
	gl.Uniform(visionMaskCoverageUniforms.sectorRadius, sectorRange)
	gl.Uniform(visionMaskCoverageUniforms.sectorEnabled, sectorEnabled)
	gl.Uniform(visionMaskCoverageUniforms.featherWidth, visionMaskCoverageFeatherWorld)
	gl.Uniform(visionMaskCoverageUniforms.terrainEnabled, TERRAIN_VISIBILITY.enabled and 1.0 or 0.0)
	gl.Uniform(visionMaskCoverageUniforms.terrainSampleSpacing, TERRAIN_VISIBILITY.sampleSpacing)
	gl.Uniform(visionMaskCoverageUniforms.terrainClearance, TERRAIN_VISIBILITY.clearance)
	gl.Uniform(visionMaskCoverageUniforms.terrainSoftness, TERRAIN_VISIBILITY.softness)
	gl.Uniform(visionMaskCoverageUniforms.terrainTargetLift, TERRAIN_VISIBILITY.targetLift)

	local extent = max(circleRadius, sectorEnabled >= 0.5 and sectorRange or 0) + visionMaskCoverageFeatherWorld
	gl.BeginEnd(GL.QUADS, function()
		gl.Vertex(cx - extent, cz - extent, 0)
		gl.Vertex(cx + extent, cz - extent, 0)
		gl.Vertex(cx + extent, cz + extent, 0)
		gl.Vertex(cx - extent, cz + extent, 0)
	end)
end

local function InitializeVisionMaskTexture()
	if not gl.CreateTexture or not gl.RenderToTexture then
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

	local worldPerTexelX = mapX / max(1, visionMaskWidth)
	local worldPerTexelZ = mapZ / max(1, visionMaskHeight)
	visionMaskCoverageFeatherWorld = max(worldPerTexelX, worldPerTexelZ) * MASK_COVERAGE_FEATHER_TEXELS

	local ok, texture = pcall(
		gl.CreateTexture,
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
		Spring.Echo("[MCL FOW r27] ERROR: could not create visibility-mask FBO texture.")
		visionMaskFailed = true
		return false
	end

	visionMaskTexture = texture
	visionMaskReady = true
	Spring.Echo("[MCL FOW r27] Visibility mask created at " .. visionMaskWidth .. "x" .. visionMaskHeight .. ".")
	return true
end

local function RenderVisionMaskContents()
	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end

	gl.Viewport(0, 0, visionMaskWidth, visionMaskHeight)
	gl.Clear(GL.COLOR_BUFFER_BIT, 0, 0, 0, 0)
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Texture(false)
	gl.Blending(GL.ONE, GL.ONE)
	gl.Color(1, 1, 1, 1)

	gl.MatrixMode(GL.PROJECTION)
	gl.PushMatrix()
	gl.LoadIdentity()
	gl.Ortho(0, Game.mapSizeX, 0, Game.mapSizeZ, -1, 1)

	gl.MatrixMode(GL.MODELVIEW)
	gl.PushMatrix()
	gl.LoadIdentity()

	gl.Texture(0, "$heightmap")

	if visionMaskCoverageShaderReady and gl.UseShader(visionMaskCoverageShader) then
		for i = 1, #alliedMechs do
			local entry = alliedMechs[i]
			if Spring.GetUnitDefID(entry.unitID) == entry.unitDefID then
				-- A transported Mech (for example while descending inside a dropship)
				-- must not project its directional cockpit sector through the transport.
				local transporterID = Spring.GetUnitTransporter and Spring.GetUnitTransporter(entry.unitID)
				if not transporterID then
					local info = unitDefInfos[entry.unitDefID]
					local cx, cy, cz, heading = ResolveCockpitPose(entry.unitID, entry.unitDefID)

					if info and cx then
						local sectorRange = (Spring.GetUnitRulesParam(entry.unitID, "sectorradius") or RADAR) - SECTOR_RANGE_INSET
						sectorRange = max(LOS + 1, sectorRange)
						DrawSmoothMaskSource(cx, cy, cz, LOS, heading, info.halfAngle, sectorRange, 1.0)
					end
				end
			end
		end

		for i = 1, #alliedCircularLosSources do
			local entry = alliedCircularLosSources[i]
			if Spring.GetUnitDefID(entry.unitID) == entry.unitDefID then
				local transporterID = Spring.GetUnitTransporter and Spring.GetUnitTransporter(entry.unitID)
				if not transporterID then
					local radius = GetLiveLosRadius(entry.unitID, entry.unitDefID)
					if radius > 0 then
						local cx, cy, cz = ResolveCircularLosPose(entry.unitID, entry.unitDefID)
						if cx then
							DrawSmoothMaskSource(cx, cy, cz, radius, 0, 0, 0, 0.0)
						end
					end
				end
			end
		end

		gl.UseShader(0)
	end
	gl.Texture(0, false)

	gl.UseShader(0)
	gl.PopMatrix()
	gl.MatrixMode(GL.PROJECTION)
	gl.PopMatrix()
	gl.MatrixMode(GL.MODELVIEW)

	if gl.PopAttrib then
		gl.PopAttrib()
	end
end

local function UpdateVisionMask()
	if not visionMaskReady or visionMaskFailed then
		return false
	end

	RefreshAlliedMechs(false)

	local drawFrame
	if Spring.GetDrawFrame then
		local low, high = Spring.GetDrawFrame()
		if low then
			drawFrame = low + (high or 0) * 65536
		end
	end
	drawFrame = drawFrame or ((Spring.GetGameFrame and Spring.GetGameFrame()) or 0)

	if drawFrame - lastVisionMaskDrawFrame < VISION_MASK_UPDATE_FRAMES then
		return true
	end

	lastVisionMaskDrawFrame = drawFrame
	local ok, err = pcall(gl.RenderToTexture, visionMaskTexture, RenderVisionMaskContents)
	if not ok then
		Spring.Echo("[MCL FOW r27] ERROR: visibility-mask update failed: " .. tostring(err))
		visionMaskFailed = true
		visionMaskHasData = false
		return false
	end

	visionMaskHasData = true
	if not loggedFirstMaskUpdate then
		loggedFirstMaskUpdate = true
		Spring.Echo("[MCL FOW r27] First visibility-mask render completed successfully in DrawGenesis().")
	end

	return true
end

local function InitializeExploredMaskTextures()
	if not visionMaskReady or not gl.CreateTexture then
		return false
	end

	for i = 1, 2 do
		local ok, texture = pcall(
			gl.CreateTexture,
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
			Spring.Echo("[MCL FOW r27] ERROR: could not create explored-mask FBO texture " .. i .. ".")
			exploredMaskFailed = true
			return false
		end

		exploredMaskTextures[i] = texture
	end

	exploredMaskReady = true
	return true
end

function VIEW_STATE.StoreActiveExploredBank()
	local key = VIEW_STATE.activeExploredKey
	if key == nil then
		return
	end

	local bank = VIEW_STATE.exploredBanks[key]
	if not bank then
		return
	end

	bank.textures = exploredMaskTextures
	bank.index = exploredMaskIndex
	bank.ready = exploredMaskReady
	bank.failed = exploredMaskFailed
	bank.hasData = exploredMaskHasData
	bank.lastFrame = lastExploredMaskFrame
end

function VIEW_STATE.ActivateExploredBank(allyTeamID)
	local key = allyTeamID
	if key == nil then
		key = -1
	end

	if VIEW_STATE.activeExploredKey == key then
		return exploredMaskReady and not exploredMaskFailed
	end

	VIEW_STATE.StoreActiveExploredBank()

	local bank = VIEW_STATE.exploredBanks[key]
	if bank then
		exploredMaskTextures = bank.textures
		exploredMaskIndex = bank.index or 1
		exploredMaskReady = bank.ready == true
		exploredMaskFailed = bank.failed == true
		exploredMaskHasData = bank.hasData == true
		lastExploredMaskFrame = bank.lastFrame or -999999
	else
		exploredMaskTextures = {nil, nil}
		exploredMaskIndex = 1
		exploredMaskReady = false
		exploredMaskFailed = false
		exploredMaskHasData = false
		lastExploredMaskFrame = -999999

		if not InitializeExploredMaskTextures() then
			return false
		end

		bank = {
			textures = exploredMaskTextures,
			index = exploredMaskIndex,
			ready = exploredMaskReady,
			failed = exploredMaskFailed,
			hasData = exploredMaskHasData,
			lastFrame = lastExploredMaskFrame,
		}
		VIEW_STATE.exploredBanks[key] = bank
	end

	VIEW_STATE.activeExploredKey = key
	MINIMAP_STYLE.lastFogTextureFrame = -999999
	MINIMAP_STYLE.fogTextureHasData = false
	return exploredMaskReady and not exploredMaskFailed
end

function VIEW_STATE.RefreshPerspective(force)
	local spectating, fullView, fullSelect = false, false, false
	if Spring.GetSpectatingState then
		spectating, fullView, fullSelect = Spring.GetSpectatingState()
	end

	local teamID = Spring.GetMyTeamID and Spring.GetMyTeamID() or nil
	local allyTeamID = nil
	if teamID ~= nil and Spring.GetTeamAllyTeamID then
		allyTeamID = Spring.GetTeamAllyTeamID(teamID)
	end
	if allyTeamID == nil then
		if Spring.GetMyAllyTeamID then
			allyTeamID = Spring.GetMyAllyTeamID()
		elseif Spring.GetLocalAllyTeamID then
			allyTeamID = Spring.GetLocalAllyTeamID()
		end
	end

	local perspectiveChanged = force
		or spectating ~= VIEW_STATE.spectating
		or fullView ~= VIEW_STATE.fullView
		or fullSelect ~= VIEW_STATE.fullSelect
		or teamID ~= VIEW_STATE.teamID
		or allyTeamID ~= VIEW_STATE.allyTeamID

	if not perspectiveChanged then
		return false
	end

	local oldAllyTeamID = VIEW_STATE.allyTeamID
	VIEW_STATE.spectating = spectating == true
	VIEW_STATE.fullView = fullView == true
	VIEW_STATE.fullSelect = fullSelect == true
	VIEW_STATE.teamID = teamID
	VIEW_STATE.allyTeamID = allyTeamID
	lastAlliedRefreshFrame = -999999

	if visionMaskReady and (force or allyTeamID ~= oldAllyTeamID or VIEW_STATE.activeExploredKey == nil) then
		if not VIEW_STATE.ActivateExploredBank(allyTeamID) then
			Spring.Echo("[MCL FOW r27] WARNING: could not activate Explored-memory bank for allyteam " .. tostring(allyTeamID) .. ".")
		end
	end

	if VIEW_STATE.spectating then
		if VIEW_STATE.fullView then
			Spring.Echo("[MCL FOW r27] Spectator full-view active: FOW presentation bypassed; gameplay LOS state remains untouched.")
		else
			Spring.Echo("[MCL FOW r27] Spectator team POV active: team " .. tostring(teamID) .. ", allyteam " .. tostring(allyTeamID) .. ".")
		end
	end

	return true
end

function VIEW_STATE.ShouldDrawFog()
	return VIEW_STATE.fowEnabled and not VIEW_STATE.fullView
end

local function InitializeExploredUpdateShader()
	if not exploredMaskReady or not gl.CreateShader or not gl.UseShader or not gl.GetUniformLocation or not gl.Uniform then
		return false
	end

	exploredUpdateShader = gl.CreateShader({
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
		Spring.Echo("[MCL FOW r27] ERROR: explored-mask update shader failed to compile.")
		if gl.GetShaderLog then
			local log = gl.GetShaderLog()
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
		local location = gl.GetUniformLocation(exploredUpdateShader, name)
		if type(location) ~= "number" or location < 0 then
			Spring.Echo("[MCL FOW r27] ERROR: missing explored-mask shader uniform " .. name .. ".")
			if gl.DeleteShader then
				gl.DeleteShader(exploredUpdateShader)
			end
			exploredUpdateShader = nil
			exploredUpdateUniforms = {}
			return false
		end
		
		exploredUpdateUniforms[name] = location
	end

	exploredUpdateShaderReady = true
	Spring.Echo("[MCL FOW r27] Explored-memory mask update shader active.")
	return true
end

local loggedNativeLosBindFailure = false

local function DrawFullscreenUnitQuad()
	gl.BeginEnd(GL.QUADS, function()
		gl.TexCoord(0, 0)
		gl.Vertex(-1, -1, 0, 1)
		gl.TexCoord(1, 0)
		gl.Vertex( 1, -1, 0, 1)
		gl.TexCoord(1, 1)
		gl.Vertex( 1,  1, 0, 1)
		gl.TexCoord(0, 1)
		gl.Vertex(-1,  1, 0, 1)
	end)
end

local function RenderExploredMaskContents(previousExploredTexture)
	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end

	gl.Viewport(0, 0, visionMaskWidth, visionMaskHeight)
	gl.Clear(GL.COLOR_BUFFER_BIT, 0, 0, 0, 0)
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	gl.Color(1, 1, 1, 1)

	local nativeLosAvailable = 0.0
	if not gl.Texture(0, visionMaskTexture) then
		if gl.PopAttrib then
			gl.PopAttrib()
		end
		return false
	end
	if gl.Texture(1, NATIVE_LOS_TEXTURE) then
		nativeLosAvailable = 1.0
	else
		gl.Texture(1, false)
		if not loggedNativeLosBindFailure then
			loggedNativeLosBindFailure = true
			Spring.Echo("[MCL FOW r27] WARNING: could not bind " .. NATIVE_LOS_TEXTURE .. "; explored memory will currently use Mech sectors only.")
		end
	end
	local previousExploredAvailable = 0.0
	if previousExploredTexture then
		previousExploredAvailable = 1.0
		gl.Texture(2, previousExploredTexture)
	else
		gl.Texture(2, false)
	end

	if gl.UseShader(exploredUpdateShader) then
		gl.Uniform(exploredUpdateUniforms.sectorMaskTexelSize, 1 / visionMaskWidth, 1 / visionMaskHeight)
		gl.Uniform(exploredUpdateUniforms.edgeLow, FOG_EDGE_LOW)
		gl.Uniform(exploredUpdateUniforms.edgeHigh, FOG_EDGE_HIGH)
		gl.Uniform(exploredUpdateUniforms.edgeSampleRadius, FOG_EDGE_SAMPLE_RADIUS)
		gl.Uniform(exploredUpdateUniforms.nativeLosAvailable, nativeLosAvailable)
		gl.Uniform(exploredUpdateUniforms.previousExploredAvailable, previousExploredAvailable)
		DrawFullscreenUnitQuad()
		gl.UseShader(0)
	end

	gl.Texture(2, false)
	gl.Texture(1, false)
	gl.Texture(0, false)

	if gl.PopAttrib then
		gl.PopAttrib()
	end
	return true
end

local function UpdateExploredMask()
	if not exploredMaskReady or exploredMaskFailed or not visionMaskHasData or not exploredUpdateShaderReady then
		return false
	end

	local frame = (Spring.GetGameFrame and Spring.GetGameFrame()) or 0
	if frame - lastExploredMaskFrame < EXPLORED_MASK_UPDATE_FRAMES then
		return true
	end

	lastExploredMaskFrame = frame
	local readIndex = exploredMaskIndex
	local writeIndex = (readIndex == 1) and 2 or 1
	local readTexture = exploredMaskHasData and exploredMaskTextures[readIndex] or nil
	local writeTexture = exploredMaskTextures[writeIndex]

	local ok, err = pcall(gl.RenderToTexture, writeTexture, function()
		RenderExploredMaskContents(readTexture)
	end)
	if not ok then
		Spring.Echo("[MCL FOW r27] ERROR: explored-mask update failed: " .. tostring(err))
		exploredMaskFailed = true
		exploredMaskHasData = false
		VIEW_STATE.StoreActiveExploredBank()
		return false
	end

	exploredMaskIndex = writeIndex
	exploredMaskHasData = true
	VIEW_STATE.StoreActiveExploredBank()
	if not loggedFirstExploredUpdate then
		loggedFirstExploredUpdate = true
		Spring.Echo("[MCL FOW r27] First explored-memory update completed successfully in DrawGenesis().")
	end

	return true
end

--------------------------------------------------------------------------------
-- Deferred model-depth capture
--------------------------------------------------------------------------------

local function DeleteModelDepthCaptureTextures()
	if unitDepthTexture and gl.DeleteTexture then
		gl.DeleteTexture(unitDepthTexture)
	end
	if featureDepthTexture and gl.DeleteTexture then
		gl.DeleteTexture(featureDepthTexture)
	end
	unitDepthTexture = nil
	featureDepthTexture = nil
	unitDepthHasData = false
	featureDepthHasData = false
end

local function InitializeModelDepthCaptureTextures()
	if not gl.CreateTexture or not gl.RenderToTexture then
		return false
	end

	local width, height = 0, 0
	if gl.GetViewSizes then
		width, height = gl.GetViewSizes()
	end
	if not width or width <= 0 or not height or height <= 0 then
		width, height = Spring.GetViewGeometry()
	end
	width = max(1, math.floor(width or 1))
	height = max(1, math.floor(height or 1))

	DeleteModelDepthCaptureTextures()

	local function CreateDepthTexture()
		local ok, texture = pcall(
			gl.CreateTexture,
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
		Spring.Echo("[MCL FOW r27] WARNING: could not create model-depth capture textures; final FOW will fall back to map depth where model depth is unavailable.")
		return false
	end

	modelDepthWidth = width
	modelDepthHeight = height
	Spring.Echo("[MCL FOW r27] Model-depth capture textures created at " .. width .. "x" .. height .. ".")
	return true
end

local function InitializeDepthCopyShader()
	if not gl.CreateShader or not gl.UseShader then
		return false
	end

	depthCopyShader = gl.CreateShader({
		vertex = FOG_VERTEX_SHADER,
		fragment = DEPTH_COPY_FRAGMENT_SHADER,
		uniformInt = {
			sourceDepthTex = 0,
		},
	})

	if not depthCopyShader then
		Spring.Echo("[MCL FOW r27] WARNING: model-depth copy shader failed to compile.")
		if gl.GetShaderLog then
			local log = gl.GetShaderLog()
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
	gl.BeginEnd(GL.QUADS, function()
		gl.TexCoord(0, 0)
		gl.Vertex(-1, -1, 0, 1)
		gl.TexCoord(1, 0)
		gl.Vertex( 1, -1, 0, 1)
		gl.TexCoord(1, 1)
		gl.Vertex( 1,  1, 0, 1)
		gl.TexCoord(0, 1)
		gl.Vertex(-1,  1, 0, 1)
	end)
end

local function ClearCapturedDepthTexture(texture)
	if not texture then
		return
	end
	pcall(gl.RenderToTexture, texture, function()
		if gl.PushAttrib then
			gl.PushAttrib(GL.ALL_ATTRIB_BITS)
		end

		gl.Viewport(0, 0, modelDepthWidth, modelDepthHeight)
		gl.DepthTest(false)
		gl.DepthMask(false)
		gl.Blending(false)
		gl.Color(1, 1, 1, 1)
		gl.Clear(GL.COLOR_BUFFER_BIT, 1, 0, 0, 1)

		if gl.PopAttrib then
			gl.PopAttrib()
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
	local ok, err = pcall(gl.RenderToTexture, targetTexture, function()
		if gl.PushAttrib then
			gl.PushAttrib(GL.ALL_ATTRIB_BITS)
		end

		gl.Viewport(0, 0, modelDepthWidth, modelDepthHeight)
		gl.DepthTest(false)
		gl.DepthMask(false)
		gl.Blending(false)
		gl.Color(1, 1, 1, 1)

		local depthBound = gl.Texture(0, MODEL_DEPTH_TEXTURE)
		if depthBound and gl.UseShader(depthCopyShader) then
			DrawClipSpaceQuad()
			gl.UseShader(0)
			didCopy = true
		end

		gl.UseShader(0)
		gl.Texture(0, false)

		if gl.PopAttrib then
			gl.PopAttrib()
		end
	end)

	if not ok then
		Spring.Echo("[MCL FOW r27] WARNING: model-depth capture failed: " .. tostring(err))
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
	if not visionMaskReady or not gl.CreateShader or not gl.UseShader or not gl.GetUniformLocation or not gl.Uniform then
		return false
	end

	fogShader = gl.CreateShader({
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
			organicEdgeEnabled = FOW_BOUNDARY_STYLE.enabled and 1.0 or 0.0,
			organicEdgeScale = FOW_BOUNDARY_STYLE.noiseScale,
			organicEdgeWarp = FOW_BOUNDARY_STYLE.warpWorld,
			organicEdgeDetailWeight = FOW_BOUNDARY_STYLE.detailWeight,
		},
	})

	if not fogShader then
		Spring.Echo("[MCL FOW r27] ERROR: screen-space FOW shader failed to compile.")
		if gl.GetShaderLog then
			local log = gl.GetShaderLog()
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
		"organicEdgeEnabled",
		"organicEdgeScale",
		"organicEdgeWarp",
		"organicEdgeDetailWeight",
	}

	for i = 1, #names do
		local name = names[i]
		local location = gl.GetUniformLocation(fogShader, name)
		if type(location) ~= "number" or location < 0 then
			Spring.Echo("[MCL FOW r27] ERROR: missing FOW shader uniform " .. name .. ".")
			if gl.DeleteShader then
				gl.DeleteShader(fogShader)
			end
			fogShader = nil
			fogUniforms = {}
			return false
		end
		fogUniforms[name] = location
	end

	fogShaderReady = true
	Spring.Echo("[MCL FOW r27] Screen-space depth-reconstructed GLSL 1.30 fog compositor active; camera inverse supplied by compatibility GLSL state.")
	return true
end

local function ValidateScreenFogRenderer()
	Spring.Echo("[MCL FOW r27] Screen-space fog renderer ready; using GLSL compatibility inverse camera matrix.")
	Spring.Echo("[MCL FOW r27] Final-scene fog compositor will combine map, captured unit, and captured feature depth.")
	Spring.Echo("[MCL FOW r27] Unified Mech circle/sector mask and transport suppression active.")
	Spring.Echo("[MCL FOW r27] Organic Unexplored/Explored boundary active; exploration state itself remains unmodified.")
	return true
end

local function BeginFogShader()
	if not fogShaderReady or not fogShader or not visionMaskTexture or not exploredMaskReady then
		return false
	end

	if not gl.Texture(0, visionMaskTexture) then
		return false
	end
	if not gl.Texture(1, exploredMaskTextures[exploredMaskIndex]) then
		gl.Texture(0, false)
		return false
	end
	if not gl.Texture(2, MAP_DEPTH_TEXTURE) then
		gl.Texture(1, false)
		gl.Texture(0, false)
		if not loggedDepthTextureFailure then
			loggedDepthTextureFailure = true
			Spring.Echo("[MCL FOW r27] ERROR: could not bind " .. MAP_DEPTH_TEXTURE .. "; final screen-space FOW cannot render.")
		end
		return false
	end

	local nativeLosAvailable = 0.0
	if gl.Texture(3, NATIVE_LOS_TEXTURE) then
		nativeLosAvailable = 1.0
	else
		gl.Texture(3, false)
		if not loggedNativeLosBindFailure then
			loggedNativeLosBindFailure = true
			Spring.Echo("[MCL FOW r27] WARNING: could not bind " .. NATIVE_LOS_TEXTURE .. "; only custom Mech sight will contribute to current visibility.")
		end
	end

	local unitAvailable = 0.0
	if unitDepthHasData and unitDepthTexture and gl.Texture(4, unitDepthTexture) then
		unitAvailable = 1.0
	else
		gl.Texture(4, false)
	end

	local featureAvailable = 0.0
	if featureDepthHasData and featureDepthTexture and gl.Texture(5, featureDepthTexture) then
		featureAvailable = 1.0
	else
		gl.Texture(5, false)
	end

	if not gl.UseShader(fogShader) then
		gl.Texture(5, false)
		gl.Texture(4, false)
		gl.Texture(3, false)
		gl.Texture(2, false)
		gl.Texture(1, false)
		gl.Texture(0, false)
		return false
	end

	gl.Uniform(fogUniforms.mapSize, Game.mapSizeX, Game.mapSizeZ)
	gl.Uniform(fogUniforms.sectorMaskTexelSize, 1 / visionMaskWidth, 1 / visionMaskHeight)
	gl.Uniform(fogUniforms.fogColor, FOG_COLOR[1], FOG_COLOR[2], FOG_COLOR[3])
	gl.Uniform(fogUniforms.unexploredFogAlpha, UNEXPLORED_FOG_ALPHA)
	gl.Uniform(fogUniforms.exploredFogAlpha, EXPLORED_FOG_ALPHA)
	gl.Uniform(fogUniforms.visibleFogAlpha, VISIBLE_FOG_ALPHA)
	gl.Uniform(fogUniforms.edgeLow, FOG_EDGE_LOW)
	gl.Uniform(fogUniforms.edgeHigh, FOG_EDGE_HIGH)
	gl.Uniform(fogUniforms.edgeSampleRadius, FOG_EDGE_SAMPLE_RADIUS)
	-- Native $info:los is intentionally excluded from final Visible presentation;
	-- it remains active for engine gameplay and Explored-memory accumulation.
	gl.Uniform(fogUniforms.nativeLosAvailable, 0.0)
	gl.Uniform(fogUniforms.unitDepthAvailable, unitAvailable)
	gl.Uniform(fogUniforms.featureDepthAvailable, featureAvailable)
	gl.Uniform(fogUniforms.organicEdgeEnabled, FOW_BOUNDARY_STYLE.enabled and 1.0 or 0.0)
	gl.Uniform(fogUniforms.organicEdgeScale, FOW_BOUNDARY_STYLE.noiseScale)
	gl.Uniform(fogUniforms.organicEdgeWarp, FOW_BOUNDARY_STYLE.warpWorld)
	gl.Uniform(fogUniforms.organicEdgeDetailWeight, FOW_BOUNDARY_STYLE.detailWeight)
	return true
end

local function EndFogShader()
	gl.UseShader(0)
	gl.Texture(5, false)
	gl.Texture(4, false)
	gl.Texture(3, false)
	gl.Texture(2, false)
	gl.Texture(1, false)
	gl.Texture(0, false)
end

local function DrawFullscreenFogQuad()
	DrawClipSpaceQuad()
end

local function DrawCustomFog()
	if not VIEW_STATE.ShouldDrawFog() then
		return
	end
	if not visionMaskReady or visionMaskFailed or not visionMaskHasData or not exploredMaskReady or not exploredMaskHasData or not fogShaderReady then
		return
	end

	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	gl.Color(1, 1, 1, 1)

	if BeginFogShader() then
		DrawFullscreenFogQuad()
		EndFogShader()
	end

	gl.Color(1, 1, 1, 1)
	gl.DepthMask(true)
	gl.DepthTest(false)
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function widget:Initialize()
	for unitDefID, unitDef in ipairs(UnitDefs) do
		local halfAngle = GetUnitDefHalfAngle(unitDef)
		if halfAngle then
			unitDefInfos[unitDefID] = {
				halfAngle = halfAngle,
			}
		end
	end

	if Spring.GetMapDrawMode then
		engineLosWasActive = (Spring.GetMapDrawMode() == "los")
	end
	SuppressNativeLosOverlay()

	if not InitializeVisionMaskTexture() then
		Spring.Echo("[MCL FOW r27] Custom FOW disabled because the visibility mask could not be created.")
		return
	end
	if not InitializeVisionMaskCoverageShader() then
		Spring.Echo("[MCL FOW r27] Custom FOW disabled because smooth visibility-mask coverage could not be initialized.")
		return
	end

	VIEW_STATE.RefreshPerspective(true)
	if not exploredMaskReady or exploredMaskFailed then
		Spring.Echo("[MCL FOW r27] Custom FOW disabled because the active allyteam Explored-memory textures could not be created.")
		return
	end
	RefreshAlliedMechs(true)

	if not InitializeExploredUpdateShader() then
		Spring.Echo("[MCL FOW r27] Custom FOW disabled because the explored-memory update shader could not be created.")
		return
	end

	InitializeModelDepthCaptureTextures()
	InitializeDepthCopyShader()

	if not InitializeFogShader() then
		Spring.Echo("[MCL FOW r27] Custom FOW disabled because the fog shader could not be created.")
		return
	end

	MINIMAP_STYLE.InitializeFogShader()
	MINIMAP_STYLE.InitializeFogTexture()

	if not ValidateScreenFogRenderer() then
		Spring.Echo("[MCL FOW r27] Custom FOW disabled because screen-space depth fog rendering is unavailable.")
		return
	end

	Spring.Echo("[MCL FOW r27] Native LOS overlay suppressed; custom MCL FOW is authoritative for map presentation.")
	Spring.Echo("[MCL FOW r27] Final Visible presentation uses the custom 1024 Mech close-sight/sector mask; native LOS remains active for gameplay and Explored-memory tracking.")
	Spring.Echo("[MCL FOW r27] Terrain-aware visual occlusion active: custom Mech sight is ray-tested against the live $heightmap from cockpit height.")
	Spring.Echo("[MCL FOW r27] Allied non-sector LOS providers are mirrored into the custom Visible mask using their live circular sight radius.")
	Spring.Echo("[MCL FOW r27] Tactical AR, radar, BAP and ECM presentation is intentionally delegated to mcl_gui_rings.lua.")
	Spring.Echo("[MCL FOW r27] Minimap uses a cached visual overlay built from the same Unexplored / Explored / Visible state as the world.")
	Spring.Echo("[MCL FOW r27] Allyteam-aware player/spectator perspectives and visual-only /fow toggle active.")
end

function widget:Shutdown()
	if MINIMAP_STYLE.fogTexture and gl.DeleteTexture then
		gl.DeleteTexture(MINIMAP_STYLE.fogTexture)
	end
	MINIMAP_STYLE.fogTexture = nil
	MINIMAP_STYLE.fogTextureReady = false
	MINIMAP_STYLE.fogTextureHasData = false
	MINIMAP_STYLE.loggedFirstFogTextureUpdate = false
	MINIMAP_STYLE.loggedFirstForegroundDraw = false

	if MINIMAP_STYLE.fogShader and gl.DeleteShader then
		gl.DeleteShader(MINIMAP_STYLE.fogShader)
	end
	MINIMAP_STYLE.fogShader = nil
	MINIMAP_STYLE.fogShaderReady = false
	MINIMAP_STYLE.uniforms = {}

	if fogShader and gl.DeleteShader then
		gl.DeleteShader(fogShader)
	end
	fogShader = nil
	fogShaderReady = false
	fogUniforms = {}

	if exploredUpdateShader and gl.DeleteShader then
		gl.DeleteShader(exploredUpdateShader)
	end
	exploredUpdateShader = nil
	exploredUpdateShaderReady = false
	exploredUpdateUniforms = {}

	if depthCopyShader and gl.DeleteShader then
		gl.DeleteShader(depthCopyShader)
	end
	depthCopyShader = nil
	depthCopyShaderReady = false
	DeleteModelDepthCaptureTextures()

	if visionMaskCoverageShader and gl.DeleteShader then
		gl.DeleteShader(visionMaskCoverageShader)
	end
	visionMaskCoverageShader = nil
	visionMaskCoverageShaderReady = false
	visionMaskCoverageUniforms = {}

	if visionMaskTexture and gl.DeleteTexture then
		gl.DeleteTexture(visionMaskTexture)
	end
	visionMaskTexture = nil
	visionMaskReady = false
	visionMaskHasData = false

	VIEW_STATE.StoreActiveExploredBank()
	do
		local deletedTextures = {}
		for _, bank in pairs(VIEW_STATE.exploredBanks) do
			local textures = bank.textures or {}
			for i = 1, 2 do
				local texture = textures[i]
				if texture and not deletedTextures[texture] and gl.DeleteTexture then
					gl.DeleteTexture(texture)
					deletedTextures[texture] = true
				end
				textures[i] = nil
			end
		end
	end
	VIEW_STATE.exploredBanks = {}
	VIEW_STATE.activeExploredKey = nil
	exploredMaskTextures = {nil, nil}
	exploredMaskReady = false
	exploredMaskHasData = false

	-- Restore native LOS only when it was active before this widget took over,
	-- and only if the user is currently in ordinary map mode.
	if engineLosWasActive and Spring.GetMapDrawMode and Spring.SendCommands and Spring.GetMapDrawMode() == "normal" then
		Spring.SendCommands("showlos")
	end
end

function widget:Update(dt)
	VIEW_STATE.RefreshPerspective(false)
	engineLosCheckAccumulator = engineLosCheckAccumulator + (dt or 0)
	if engineLosCheckAccumulator >= ENGINE_LOS_CHECK_INTERVAL then
		engineLosCheckAccumulator = 0
		SuppressNativeLosOverlay()
	end
end

function widget:PlayerChanged()
	VIEW_STATE.RefreshPerspective(true)
end

function widget:TextCommand(command)
	local normalized = string.lower(tostring(command or ""))
	normalized = string.match(normalized, "^%s*(.-)%s*$") or normalized
	if normalized ~= "fow" then
		return false
	end

	VIEW_STATE.RefreshPerspective(false)
	local cheatsEnabled = Spring.IsCheatingEnabled and Spring.IsCheatingEnabled() or false
	if not VIEW_STATE.spectating and not cheatsEnabled then
		Spring.Echo("[MCL FOW r27] /fow requires /cheat while playing. Spectators may use it freely.")
		return true
	end

	VIEW_STATE.fowEnabled = not VIEW_STATE.fowEnabled
	if VIEW_STATE.fowEnabled then
		Spring.Echo("[MCL FOW r27] FOW presentation ON. Unexplored / Explored / Visible state was preserved while hidden.")
	else
		Spring.Echo("[MCL FOW r27] FOW presentation OFF. This is visual only; LOS, detection and exploration tracking continue unchanged.")
	end
	return true
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
		if UpdateVisionMask() and not VIEW_STATE.fullView then
			UpdateExploredMask()
			MINIMAP_STYLE.UpdateFogTexture()
		end
	end

	if unitDepthTexture or featureDepthTexture then
		ClearModelDepthCaptures()
	end
end

function widget:DrawWorldPreUnit()
	-- Intentionally empty in r27. Fog is composited after opaque units/features
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

function widget:DrawInMiniMapBackground(sx, sy)
	-- Intentionally empty in r27. The pre-rendered minimap FOW texture is drawn
	-- in DrawInMiniMap instead. This does not change visibility state or FOW
	-- generation; it only moves the final minimap compositing stage.
end

function widget:DrawInMiniMap(sx, sy)
	-- FOW owns only the cached three-state minimap compositor. Tactical sensor
	-- and AR overlays are rendered by mcl_gui_rings.lua.
	if not MINIMAP_STYLE.loggedFirstForegroundDraw then
		MINIMAP_STYLE.loggedFirstForegroundDraw = true
		Spring.Echo("[MCL FOW r27] DrawInMiniMap foreground compositor reached; drawing cached minimap FOW texture.")
	end
	MINIMAP_STYLE.DrawFog(sx, sy)
end

function widget:DrawWorld()
	-- One final fog pass covers the already-rendered opaque world. Tactical AR,
	-- range and sensor overlays deliberately live in mcl_gui_rings.lua.
	DrawCustomFog()
end
