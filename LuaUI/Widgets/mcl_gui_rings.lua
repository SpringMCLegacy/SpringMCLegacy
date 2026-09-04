-- Tactical rings revision 30
function widget:GetInfo()
  return {
    name      = "MC:L - Minimum Ranges",
    desc      = "Draws weapon/salvage ranges plus selected-unit sight-sector AR, merged radar coverage, and live ECM coverage",
    author    = "FLOZi (C. Lawrence) + zvero + ChatGPT",
    date      = "28/07/2013; direct-control/zoom/GL4 diffusion integration 2026",
    license   = "GNU GPL v2",
    layer     = 0,
    enabled   = true,
  }
end

-- localisations

-- OGL
local glBillboard	 		= gl.Billboard
local glColor 				= gl.Color
local glDrawGroundCircle 	= gl.DrawGroundCircle
local glTranslate			= gl.Translate
local glBeginEnd			= gl.BeginEnd
local glVertex				= gl.Vertex
-- SyncedRead
local GetUnitPosition 		= Spring.GetUnitPosition
local GetUnitDefID			= Spring.GetUnitDefID
local GetGroundHeight		= Spring.GetGroundHeight
local GetUnitRulesParam		= Spring.GetUnitRulesParam
-- UnsyncedRead
local GetActiveCommand		= Spring.GetActiveCommand
local GetSelectedUnits		= Spring.GetSelectedUnits
local GetCameraPosition		= Spring.GetCameraPosition
local LoadCmdColorsConfig	= Spring.LoadCmdColorsConfig

local sqrt = math.sqrt
local min = math.min
local max = math.max
local sin = math.sin
local cos = math.cos
local pi = math.pi

-- GL4 ring renderer. The static VBO is a normalized annulus; each draw supplies
-- the world-space centre/radius/width as uniforms and the vertex shader drapes
-- the ring over Recoil's live heightmap.
local LuaShader = gl.LuaShader

-- Visual tuning
-- RING_THICKNESS controls the ring width. RING_ALPHA controls its base opacity.
-- BAND_THICKNESS is the world-space diffusion distance from the range boundary:
-- inward for maximum/salvage ranges and outward for minimum ranges.
-- MAX_BAND_ALPHA fades linearly to MIN_BAND_ALPHA across BAND_THICKNESS.
-- MIN_RANGE_DASH_FILL controls the dashed minimum-range ring duty cycle:
-- 1.0 = solid ring, 0.5 = equal dash/gap, 0.0 = no ring.
-- Minimum-range bands use diagonal hazard stripes.
-- MIN_RANGE_HAZARD_ALPHA controls stripe opacity, MIN_RANGE_HAZARD_SIZE controls
-- their approximate world-space pitch, and MIN_RANGE_HAZARD_FILL controls the
-- stripe/gap duty cycle (0.5 = equal stripe and gap).
-- Ring and band alpha are automatically reduced as the camera zooms farther out.
-- These RGB controls apply to the full range treatment: crisp ring, diffusion,
-- and (for minimum ranges) hazard stripes. Alpha remains controlled
-- separately by the existing opacity settings below.
local MAX_RANGE_RING_RGB = {1.00, 0.20, 0.20}
local MIN_RANGE_RING_RGB = {1.00, 0.82, 0.12}
local SALVAGE_RANGE_RING_RGB = {0.77647, 0.88627, 1.00}

local RING_THICKNESS = 1.5
local RING_ALPHA = 0.70
local BAND_THICKNESS = 20
local MAX_BAND_ALPHA = 0.15
local MIN_BAND_ALPHA = 0.00
local MIN_RANGE_DASH_FILL = 0.50
local MIN_RANGE_HAZARD_ALPHA = 0.45
local MIN_RANGE_HAZARD_SIZE = 24
local MIN_RANGE_HAZARD_FILL = 0.50

-- Renderer internals
local RING_SEGMENTS = 384
local RING_HEIGHT_OFFSET = 4
local LEGACY_RING_SEGMENTS = 96
local LEGACY_DIFFUSE_STEPS = 48
local LEGACY_DASH_STIPPLE_FACTOR = 4
local GL4_HALF_WIDTH_PER_LEGACY_PIXEL = 3.6666666667
local VISIBILITY_REFERENCE_DISTANCE = 1800
local VISIBILITY_MIN_ALPHA_MULTIPLIER = 0.15

local ringVBO
local ringVAO
local ringShader
local diffusionShader
local ringGL4Ready = false
local diffusionGL4Ready = false
local ringUniforms = {}
local diffusionUniforms = {}

-- Tactical AR/sensor presentation moved here from gui_mcl_fow.lua. These
-- settings are visual only and never contribute to FOW, LOS or detection state.
-- Keep them grouped in one table to avoid unnecessary Lua top-level locals.
local TACTICAL_STYLE = {
	drawSector = true,
	drawRadar = true,
	drawECM = true,

	sightRadius = tonumber((Spring.GetModOptions() or {}).mechsight) or 400,
	sectorFallback = tonumber((Spring.GetModOptions() or {}).sectorrange) or 1000,
	sectorInset = 50,
	groundLift = 3.0,

	-- Expensive terrain-draped tactical geometry is rebuilt at most at 60 Hz.
	-- Cached vertices are still submitted every DrawWorld frame, so this limits
	-- CPU-side sampling/reconstruction without limiting the visible HUD framerate.
	geometryRefreshSeconds = 1 / 60,

	zoomFadeStart = 1800,
	zoomFadeReference = 3600,
	zoomFadeMin = 0.22,

	sector = {
		color = {0.75, 0.75, 0.75},
		sightColor = {0.75, 0.75, 0.75},
		sightRingAlpha = 0.68,
		edgeAlpha = 0.72,
		outerArcAlpha = 0.76,
		centerlineAlpha = 0.18,
		guideArcAlpha = 0.13,
		coreLineWidth = 1.7,
		fullCircleSegments = 96,
		arcSegments = 48,
		sideLineSegments = 16,
		drawCenterline = true,
		drawGuideArc = true,
		drawTargetingRails = true,
		targetingRailAlpha = 0.16,
		targetingRailWidth = 1.0,
		targetingRailOffsetDegrees = 2.25,
	},

	radar = {
		color = {0.18, 0.92, 0.28},
		ringAlpha = 0.70,
		ringWidth = 1.7,
		diffuseWidth = 90,
		diffuseEdgeAlpha = 0.16,
		diffuseInnerAlpha = 0.00,
		ringSegments = 128,
		radialSteps = 6,
		multiRingSegments = 96,
		multiRadialSteps = 4,
		miniMapSegments = 64,
	},

	-- ECM world presentation. The visual treatment is intentionally fixed in r29;
	-- colour is the only presentation value left exposed for routine tuning.
	-- Selected emitters use the full storm/current treatment. Render-visible but
	-- unselected emitters use a cheaper, dimmer ambient tier.
	ecm = {
		color = {0.48, 0.025, 0.020},
	},

	unitDefInfos = {},
	cockpitPieceCache = {},
	sectorGeometryCache = {},
	radarGeometryCache = nil,
	ecmGeometryCache = nil,
	ecmCapableUnitDefs = {},
}

local RING_VERTEX_SHADER = [[
#version 420

#extension GL_ARB_uniform_buffer_object : require
#extension GL_ARB_shading_language_420pack : require

//__ENGINEUNIFORMBUFFERDEFS__

layout (location = 0) in vec3 ringVertex;

uniform sampler2D heightmapTex;
uniform vec3 ringCenter;
uniform float ringRadius;
uniform float ringHalfWidth;
uniform float ringHeightOffset;

out vec2 vRingDirection;
out float vRingEdge;
out vec2 vWorldXZ;

void main()
{
    float radius = ringRadius + ringVertex.z * ringHalfWidth;
    vec2 worldXZ = ringCenter.xz + ringVertex.xy * radius;
    vec2 heightUV = heightmapUVatWorldPos(worldXZ);
    float worldY = textureLod(heightmapTex, heightUV, 0.0).x + ringHeightOffset;

    vRingDirection = ringVertex.xy;
    vRingEdge = ringVertex.z;
    vWorldXZ = worldXZ;

    gl_Position = cameraViewProj * vec4(worldXZ.x, worldY, worldXZ.y, 1.0);
}
]]

local RING_FRAGMENT_SHADER = [[
#version 420

in vec2 vRingDirection;
in float vRingEdge;

uniform vec4 ringColor;
uniform float dashFill;
uniform int dashed;

out vec4 fragColor;

void main()
{
    float edge = abs(vRingEdge);

    // A narrow, crisp centre line sits inside a wider translucent feather.
    // The geometry itself therefore supplies both apparent thickness and AA
    // instead of relying on driver-specific OpenGL line rasterization.
    float feather = 1.0 - smoothstep(0.62, 1.0, edge);
    float core = 1.0 - smoothstep(0.08, 0.32, edge);
    float profile = max(core, feather * 0.35);

    float dashAlpha = 1.0;
    if (dashed != 0) {
        if (dashFill <= 0.001) {
            dashAlpha = 0.0;
        } else if (dashFill < 0.999) {
            float angle = atan(vRingDirection.y, vRingDirection.x);
            float phase = fract(((angle / 6.28318530718) + 0.5) * 24.0);
            float dashAA = max(fwidth(phase) * 1.5, 0.01);
            dashAlpha = 1.0 - smoothstep(dashFill - dashAA, dashFill + dashAA, phase);
        }
    }

    fragColor = vec4(ringColor.rgb, ringColor.a * profile * dashAlpha);
}
]]

local DIFFUSION_FRAGMENT_SHADER = [[
#version 420

in float vRingEdge;

uniform vec4 diffusionColor;
uniform float minBandAlpha;
uniform int outwardBand;

out vec4 fragColor;

void main()
{
    // Maximum/salvage bands span from the inner fade edge (-1) to the range
    // boundary (+1). Minimum-range bands are mirrored: the range boundary is
    // the inner edge (-1) and the fade extends outward to (+1).
    float boundaryBlend = (outwardBand != 0)
        ? clamp((1.0 - vRingEdge) * 0.5, 0.0, 1.0)
        : clamp((vRingEdge + 1.0) * 0.5, 0.0, 1.0);

    float diffusionAlpha = mix(minBandAlpha, diffusionColor.a, boundaryBlend);
    fragColor = vec4(diffusionColor.rgb, diffusionAlpha);
}
]]

local function InitializeGL4RingRenderer()
    if
        not LuaShader
        or not LuaShader.GetEngineUniformBufferDefs
        or not gl.GetVBO
        or not gl.GetVAO
    then
        return false
    end

    local vertexData = {}
    for i = 0, RING_SEGMENTS do
        local angle = (i / RING_SEGMENTS) * (2 * pi)
        local dx = cos(angle)
        local dz = sin(angle)

        -- Inner and outer vertices for a single triangle strip.
        vertexData[#vertexData + 1] = dx
        vertexData[#vertexData + 1] = dz
        vertexData[#vertexData + 1] = -1

        vertexData[#vertexData + 1] = dx
        vertexData[#vertexData + 1] = dz
        vertexData[#vertexData + 1] = 1
    end

    ringVBO = gl.GetVBO(GL.ARRAY_BUFFER, false)
    if not ringVBO then
        return false
    end

    ringVBO:Define(
        #vertexData / 3,
        {
            {
                id = 0,
                name = "ringVertex",
                size = 3,
            },
        }
    )
    ringVBO:Upload(vertexData)

    ringVAO = gl.GetVAO()
    if not ringVAO then
        return false
    end
    ringVAO:AttachVertexBuffer(ringVBO)

    local engineUniformBufferDefs = LuaShader.GetEngineUniformBufferDefs()
    local vertexShader = RING_VERTEX_SHADER:gsub(
        "//__ENGINEUNIFORMBUFFERDEFS__",
        engineUniformBufferDefs
    )

    ringShader = LuaShader(
        {
            vertex = vertexShader,
            fragment = RING_FRAGMENT_SHADER,
            uniformInt = {
                heightmapTex = 0,
                dashed = 0,
            },
            uniformFloat = {
                ringCenter = {0, 0, 0},
                ringRadius = 1,
                ringHalfWidth = RING_THICKNESS * GL4_HALF_WIDTH_PER_LEGACY_PIXEL,
                ringHeightOffset = RING_HEIGHT_OFFSET,
                ringColor = {1, 1, 1, 1},
                dashFill = MIN_RANGE_DASH_FILL,
            },
        },
        "MCL Range Rings GL4"
    )

    if not ringShader:Initialize() then
        ringShader = nil
        return false
    end

    local shaderObj = ringShader.shaderObj
    ringUniforms.ringCenter = gl.GetUniformLocation(shaderObj, "ringCenter")
    ringUniforms.ringRadius = gl.GetUniformLocation(shaderObj, "ringRadius")
    ringUniforms.ringHalfWidth = gl.GetUniformLocation(shaderObj, "ringHalfWidth")
    ringUniforms.ringHeightOffset = gl.GetUniformLocation(shaderObj, "ringHeightOffset")
    ringUniforms.ringColor = gl.GetUniformLocation(shaderObj, "ringColor")
    ringUniforms.dashFill = gl.GetUniformLocation(shaderObj, "dashFill")
    ringUniforms.dashed = gl.GetUniformLocation(shaderObj, "dashed")

    for _, location in pairs(ringUniforms) do
        if location == nil or location == -1 then
            ringShader:Finalize()
            ringShader = nil
            return false
        end
    end

    diffusionShader = LuaShader(
        {
            vertex = vertexShader,
            fragment = DIFFUSION_FRAGMENT_SHADER,
            uniformInt = {
                heightmapTex = 0,
                outwardBand = 0,
            },
            uniformFloat = {
                ringCenter = {0, 0, 0},
                ringRadius = 1,
                ringHalfWidth = 20,
                ringHeightOffset = RING_HEIGHT_OFFSET,
                diffusionColor = {1, 1, 1, MAX_BAND_ALPHA},
                minBandAlpha = MIN_BAND_ALPHA,
            },
        },
        "MCL Range Ring Diffusion GL4"
    )

    if diffusionShader:Initialize() then
        local diffusionShaderObj = diffusionShader.shaderObj
        diffusionUniforms.ringCenter = gl.GetUniformLocation(diffusionShaderObj, "ringCenter")
        diffusionUniforms.ringRadius = gl.GetUniformLocation(diffusionShaderObj, "ringRadius")
        diffusionUniforms.ringHalfWidth = gl.GetUniformLocation(diffusionShaderObj, "ringHalfWidth")
        diffusionUniforms.ringHeightOffset = gl.GetUniformLocation(diffusionShaderObj, "ringHeightOffset")
        diffusionUniforms.diffusionColor = gl.GetUniformLocation(diffusionShaderObj, "diffusionColor")
        diffusionUniforms.minBandAlpha = gl.GetUniformLocation(diffusionShaderObj, "minBandAlpha")
        diffusionUniforms.outwardBand = gl.GetUniformLocation(diffusionShaderObj, "outwardBand")

        diffusionGL4Ready = true
        for _, location in pairs(diffusionUniforms) do
            if location == nil or location == -1 then
                diffusionGL4Ready = false
                break
            end
        end

        if not diffusionGL4Ready then
            diffusionShader:Finalize()
            diffusionShader = nil
            diffusionUniforms = {}
        end
    else
        diffusionShader = nil
        diffusionGL4Ready = false
    end

    return true
end

local function GetRangeRingHalfWidth()
    return RING_THICKNESS * GL4_HALF_WIDTH_PER_LEGACY_PIXEL
end

local function GetDiffusionWidth()
    return BAND_THICKNESS
end

local function GetRangeVisualAlphaScale(x, y, z)
    if not GetCameraPosition then
        return 1
    end

    local cx, cy, cz = GetCameraPosition()
    if not cx then
        return 1
    end

    local dx = x - cx
    local dy = y - cy
    local dz = z - cz
    local distance = sqrt(dx * dx + dy * dy + dz * dz)

    if distance <= VISIBILITY_REFERENCE_DISTANCE then
        return 1
    end

    return max(
        VISIBILITY_MIN_ALPHA_MULTIPLIER,
        min(1, VISIBILITY_REFERENCE_DISTANCE / distance)
    )
end

local function DrawLegacyDiffusionBand(x, y, z, radius, color, alphaScale, outwardBand)
    local diffuseWidth = GetDiffusionWidth()

    gl.PushAttrib(GL.ALL_ATTRIB_BITS)
    gl.DepthTest(false)
    gl.DepthMask(false)
    gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
    gl.LineWidth(2.25)

    for i = 0, LEGACY_DIFFUSE_STEPS - 1 do
        local t = i / (LEGACY_DIFFUSE_STEPS - 1)
        local currentRadius = radius + ((outwardBand and 1 or -1) * diffuseWidth * t)
        if currentRadius > 0 then
            local alpha = (MAX_BAND_ALPHA + ((MIN_BAND_ALPHA - MAX_BAND_ALPHA) * t)) * alphaScale
            glColor(color[1] * 0.72, color[2] * 0.72, color[3] * 0.72, alpha)
            glDrawGroundCircle(x, y, z, currentRadius, LEGACY_RING_SEGMENTS)
        end
    end

    gl.LineWidth(1)
    glColor(1, 1, 1, 1)
    gl.PopAttrib()
end

local function EmitLegacyHazardVertex(worldX, worldZ, color, alpha)
    local worldY = GetGroundHeight(worldX, worldZ) + RING_HEIGHT_OFFSET + 1.0
    glColor(color[1], color[2], color[3], alpha)
    glVertex(worldX, worldY, worldZ)
end

local function DrawLegacyHazardBandGeometry(x, z, radius, color, alphaScale)
    local innerRadius = radius
    local outerRadius = radius + BAND_THICKNESS
    if innerRadius <= 0 or outerRadius <= innerRadius then
        return
    end

    local midRadius = (innerRadius + outerRadius) * 0.5
    local circumference = 2 * pi * midRadius
    local pitch = max(8, MIN_RANGE_HAZARD_SIZE)
    local stripeCount = max(12, math.floor((circumference / pitch) + 0.5))
    local period = (2 * pi) / stripeCount
    local fill = max(0.05, min(0.95, MIN_RANGE_HAZARD_FILL))
    local stripeAngle = period * fill
    local skew = period * 0.42
    local boundaryAlpha = MIN_RANGE_HAZARD_ALPHA * alphaScale

    for i = 0, stripeCount - 1 do
        local baseAngle = i * period
        local innerA0 = baseAngle
        local innerA1 = baseAngle + stripeAngle
        local outerA0 = innerA0 + skew
        local outerA1 = innerA1 + skew

        EmitLegacyHazardVertex(
            x + cos(innerA0) * innerRadius,
            z + sin(innerA0) * innerRadius,
            color,
            boundaryAlpha
        )
        EmitLegacyHazardVertex(
            x + cos(innerA1) * innerRadius,
            z + sin(innerA1) * innerRadius,
            color,
            boundaryAlpha
        )
        EmitLegacyHazardVertex(
            x + cos(outerA1) * outerRadius,
            z + sin(outerA1) * outerRadius,
            color,
            0.0
        )
        EmitLegacyHazardVertex(
            x + cos(outerA0) * outerRadius,
            z + sin(outerA0) * outerRadius,
            color,
            0.0
        )
    end
end

local function DrawLegacyHazardBand(x, y, z, radius, color, alphaScale)
    if
        not glBeginEnd
        or not glVertex
        or not GetGroundHeight
        or MIN_RANGE_HAZARD_ALPHA <= 0
        or MIN_RANGE_HAZARD_FILL <= 0
    then
        return
    end

    gl.PushAttrib(GL.ALL_ATTRIB_BITS)
    gl.Culling(false)
    gl.DepthTest(false)
    gl.DepthMask(false)
    gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
    glBeginEnd(
        GL.QUADS,
        DrawLegacyHazardBandGeometry,
        x, z, radius, color, alphaScale
    )
    glColor(1, 1, 1, 1)
    gl.PopAttrib()
end

local function DrawGL4DiffusionBand(x, y, z, radius, color, alphaScale, outwardBand)
    if not diffusionGL4Ready or not diffusionShader then
        DrawLegacyDiffusionBand(x, y, z, radius, color, alphaScale, outwardBand)
        if outwardBand then
            DrawLegacyHazardBand(x, y, z, radius, color, alphaScale)
        end
        return
    end

    local diffuseWidth = GetDiffusionWidth()
    local diffuseRadius = radius + ((outwardBand and 1 or -1) * diffuseWidth * 0.5)
    if diffuseRadius <= 0 then
        return
    end

    gl.Texture(0, "$heightmap")

    diffusionShader:Activate()
    gl.Uniform(diffusionUniforms.ringCenter, x, y, z)
    gl.Uniform(diffusionUniforms.ringRadius, diffuseRadius)
    gl.Uniform(diffusionUniforms.ringHalfWidth, diffuseWidth * 0.5)
    gl.Uniform(diffusionUniforms.ringHeightOffset, RING_HEIGHT_OFFSET)
    gl.Uniform(diffusionUniforms.diffusionColor, color[1], color[2], color[3], MAX_BAND_ALPHA * alphaScale)
    gl.Uniform(diffusionUniforms.minBandAlpha, MIN_BAND_ALPHA * alphaScale)
    gl.UniformInt(diffusionUniforms.outwardBand, outwardBand and 1 or 0)
    ringVAO:DrawArrays(GL.TRIANGLE_STRIP)
    diffusionShader:Deactivate()

    gl.Texture(0, false)

    if outwardBand then
        DrawLegacyHazardBand(x, y, z, radius, color, alphaScale)
    end
end

local function DrawGL4RangeRing(x, y, z, radius, color, dashed, halfWidth, alphaScale)
    gl.PushAttrib(GL.ALL_ATTRIB_BITS)
    gl.Culling(false)
    gl.DepthTest(false)
    gl.DepthMask(false)
    gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

    DrawGL4DiffusionBand(x, y, z, radius, color, alphaScale, dashed)

    gl.Texture(0, "$heightmap")
    ringShader:Activate()
    gl.Uniform(ringUniforms.ringCenter, x, y, z)
    gl.Uniform(ringUniforms.ringRadius, radius)
    gl.Uniform(ringUniforms.ringHalfWidth, halfWidth)
    gl.Uniform(ringUniforms.ringHeightOffset, RING_HEIGHT_OFFSET)
    gl.Uniform(ringUniforms.ringColor, color[1], color[2], color[3], RING_ALPHA * alphaScale)
    gl.Uniform(ringUniforms.dashFill, MIN_RANGE_DASH_FILL)
    gl.UniformInt(ringUniforms.dashed, dashed and 1 or 0)
    ringVAO:DrawArrays(GL.TRIANGLE_STRIP)
    ringShader:Deactivate()

    gl.Texture(0, false)
    gl.PopAttrib()
end

local function DrawRangeRing(x, y, z, radius, color, dashed, halfWidth, revealAlpha)
    revealAlpha = revealAlpha or 1
    if revealAlpha <= 0.001 then
        return
    end

    local alphaScale = GetRangeVisualAlphaScale(x, y, z) * revealAlpha

    if ringGL4Ready then
        DrawGL4RangeRing(x, y, z, radius, color, dashed, halfWidth, alphaScale)
        return
    end

    -- Compatibility path for clients without the GL4 Lua renderer.
    -- The diffusion band is still drawn so visual feedback does not silently
    -- disappear merely because the GL4 shader path is unavailable.
    DrawLegacyDiffusionBand(x, y, z, radius, color, alphaScale, dashed)
    if dashed then
        DrawLegacyHazardBand(x, y, z, radius, color, alphaScale)
    end

    glColor(color[1], color[2], color[3], RING_ALPHA * alphaScale)
    gl.LineWidth(RING_THICKNESS)

    local drawRing = true
    local stippled = false
    if dashed then
        local dashFill = max(0, min(1, MIN_RANGE_DASH_FILL))
        if dashFill <= 0 then
            drawRing = false
        elseif dashFill < 1 then
            local onBits = max(1, min(15, math.floor((dashFill * 16) + 0.5)))
            local pattern = (2 ^ onBits) - 1
            gl.LineStipple(LEGACY_DASH_STIPPLE_FACTOR, pattern)
            stippled = true
        end
    end

    if drawRing then
        glDrawGroundCircle(x, y, z, radius, LEGACY_RING_SEGMENTS)
    end
    if stippled then
        gl.LineStipple(false)
    end
    gl.LineWidth(1)
end

-- Range labels are world-space billboard text. A fixed world size grows huge on
-- screen as the camera zooms in, so scale the world size with camera distance.
-- This is camera-agnostic: stock cameras and Shooter Control use the same rule.
local RANGE_LABEL_BASE_SIZE = 20
local RANGE_LABEL_REFERENCE_DISTANCE = 1600
local RANGE_LABEL_MIN_SIZE = 9
local RANGE_LABEL_MAX_SIZE = 28
local RANGE_LABEL_ALPHA = 0.50

-- Ring RGB is configured above; text keeps its existing per-weapon colour data.
--local BuildGreen = {0.3, 1.0, 0.3, 0.5} -- doesn't match engine for some reason so make less opaque

local minRanges = {} -- minRange[unitDefID] = {weapName = range, ...}
local maxRanges = {}
local salvageRanges = {} -- salvageRange[unitDefID] = minRange

local maxRangesToDraw = {} -- maxRangesToDraw[unitDefID] = {range = string}
local minRangesToDraw = {} -- minRangesToDraw[unitDefID] = {range = string}

-- Per-weapon cache used for live filtering. The Unit Card exposes weapon state
-- through weapon_1, weapon_2, ... RulesParams; only "active" weapons contribute
-- range rings. Disabled and destroyed weapons are deliberately omitted.
local weaponRanges = {} -- weaponRanges[unitDefID] = { {weaponNum, name, maxRange, minRange, textColour}, ... }
local weapon_Lookup = {}
for i = 1, 32 do
	weapon_Lookup[i] = "weapon_" .. i
end

local function AddRangeWeapon(rangeTable, radius, name, textColour)
	if not radius then
		return
	end

	local bucket = rangeTable[radius]
	if not bucket then
		bucket = {
			names = {},
			nameSet = {},
		}
		rangeTable[radius] = bucket
	end

	if not bucket.nameSet[name] then
		bucket.nameSet[name] = true
		bucket.names[#bucket.names + 1] = (textColour or "") .. name
	end
end

local function BuildActiveWeaponRanges(unitID, unitDefID)
	local maxActive = {}
	local minActive = {}
	local cachedWeapons = weaponRanges[unitDefID]

	if not cachedWeapons then
		return maxActive, minActive
	end

	for i = 1, #cachedWeapons do
		local weapon = cachedWeapons[i]
		local rulesParam = weapon_Lookup[weapon.weaponNum]
		local status = rulesParam and GetUnitRulesParam(unitID, rulesParam)

		if status == "active" then
			AddRangeWeapon(maxActive, weapon.maxRange, weapon.name, weapon.textColour)
			AddRangeWeapon(minActive, weapon.minRange, weapon.name, weapon.textColour)
		end
	end

	local maxToDraw = {}
	local minToDraw = {}

	for radius, bucket in pairs(maxActive) do
		maxToDraw[radius] = "Max Range: " .. table.concat(bucket.names, ", ")
	end

	for radius, bucket in pairs(minActive) do
		minToDraw[radius] = "Min Range: " .. table.concat(bucket.names, ", ")
	end

	return maxToDraw, minToDraw
end


--------------------------------------------------------------------------------
-- Tactical sight-sector / radar helpers
--------------------------------------------------------------------------------

function TACTICAL_STYLE.Clamp01(value)
	if value <= 0 then
		return 0
	elseif value >= 1 then
		return 1
	end
	return value
end

function TACTICAL_STYLE.GetUnitDefHalfAngle(unitDef)
	local sectorAngle =
		unitDef
		and unitDef.customParams
		and tonumber(unitDef.customParams.sectorangle)

	if sectorAngle and sectorAngle > 0 then
		return math.rad(sectorAngle * 0.5)
	end
	return nil
end

function TACTICAL_STYLE.ResolveCockpitPose(unitID, unitDefID)
	local pieceID = TACTICAL_STYLE.cockpitPieceCache[unitDefID]

	if pieceID == nil then
		local pieceMap = Spring.GetUnitPieceMap and Spring.GetUnitPieceMap(unitID)
		pieceID = pieceMap and pieceMap["cockpit"] or false
		TACTICAL_STYLE.cockpitPieceCache[unitDefID] = pieceID
	end

	if pieceID and Spring.GetUnitPiecePosDir then
		local x, y, z, dx, dy, dz = Spring.GetUnitPiecePosDir(unitID, pieceID)
		if x and dx and dz then
			return x, z, math.atan2(dx, dz)
		end
	end

	local x, y, z = Spring.GetUnitPosition(unitID)
	if not x then
		return nil
	end

	local heading = (Spring.GetUnitHeading and Spring.GetUnitHeading(unitID)) or 0
	return x, z, heading * ((2 * pi) / 65536)
end

function TACTICAL_STYLE.GetZoomAlphaScale(x, y, z)
	local cx, cy, cz = Spring.GetCameraPosition()
	if not cx then
		return 1
	end

	local dx = x - cx
	local dy = y - cy
	local dz = z - cz
	local distance = sqrt(dx * dx + dy * dy + dz * dz)

	if distance <= TACTICAL_STYLE.zoomFadeStart then
		return 1
	end

	local scale = TACTICAL_STYLE.zoomFadeReference / distance
	return max(TACTICAL_STYLE.zoomFadeMin, min(1, scale))
end

function TACTICAL_STYLE.GetNow()
	-- FrameTimer is identical across draw call-ins in one rendered frame, which
	-- guarantees that DrawWorld and DrawInMiniMap share the same cache snapshot.
	if Spring.GetFrameTimer then
		return Spring.GetFrameTimer()
	elseif Spring.GetTimer then
		return Spring.GetTimer()
	end
	return Spring.GetGameSecondsInterpolated and Spring.GetGameSecondsInterpolated() or 0
end

function TACTICAL_STYLE.CacheIsFresh(entry, now)
	if not entry or entry.timestamp == nil then
		return false
	end

	local age
	if Spring.DiffTimers and (Spring.GetFrameTimer or Spring.GetTimer) then
		age = Spring.DiffTimers(now, entry.timestamp)
	else
		age = now - entry.timestamp
	end
	return age >= 0 and age < TACTICAL_STYLE.geometryRefreshSeconds
end

function TACTICAL_STYLE.GroundVertex(cx, cz, angle, radius)
	local x = cx + sin(angle) * radius
	local z = cz + cos(angle) * radius
	local y = GetGroundHeight(x, z) + TACTICAL_STYLE.groundLift
	return x, y, z
end

function TACTICAL_STYLE.SampleGroundArc(cx, cz, radius, startAngle, endAngle, segments, cache)
	if cache then
		local cached = cache[radius]
		if cached then
			return cached
		end
	end

	local vertices = {}
	for i = 0, segments do
		local t = i / segments
		local angle = startAngle + (endAngle - startAngle) * t
		local x, y, z = TACTICAL_STYLE.GroundVertex(cx, cz, angle, radius)
		local index = i * 3
		vertices[index + 1] = x
		vertices[index + 2] = y
		vertices[index + 3] = z
	end

	if cache then
		cache[radius] = vertices
	end
	return vertices
end

function TACTICAL_STYLE.SampleGroundRadial(cx, cz, angle, innerRadius, outerRadius, segments)
	local vertices = {}
	for i = 0, segments do
		local t = i / segments
		local radius = innerRadius + (outerRadius - innerRadius) * t
		local x, y, z = TACTICAL_STYLE.GroundVertex(cx, cz, angle, radius)
		local index = i * 3
		vertices[index + 1] = x
		vertices[index + 2] = y
		vertices[index + 3] = z
	end
	return vertices
end

function TACTICAL_STYLE.DrawSampledLine(vertices, color, alpha, width)
	if not vertices then
		return
	end
	gl.Color(color[1], color[2], color[3], alpha)
	gl.LineWidth(width)
	gl.BeginEnd(GL.LINE_STRIP, function()
		for i = 1, #vertices, 3 do
			gl.Vertex(vertices[i], vertices[i + 1], vertices[i + 2])
		end
	end)
end

function TACTICAL_STYLE.BuildSectorGeometry(unitID, unitDefID, halfAngle, sectorRange, now)
	local cx, cz, heading = TACTICAL_STYLE.ResolveCockpitPose(unitID, unitDefID)
	if not cx then
		return nil
	end

	local style = TACTICAL_STYLE.sector
	local sightRadius = TACTICAL_STYLE.sightRadius
	sectorRange = max(sightRadius + 1, sectorRange)
	local startAngle = heading - halfAngle
	local endAngle = heading + halfAngle
	local twoPi = 2 * pi
	local geometry = {
		timestamp = now,
		unitDefID = unitDefID,
		halfAngle = halfAngle,
		sectorRange = sectorRange,
		cx = cx,
		cz = cz,
		groundY = GetGroundHeight(cx, cz),
		heading = heading,
		startAngle = startAngle,
		endAngle = endAngle,
		sightArc = TACTICAL_STYLE.SampleGroundArc(cx, cz, sightRadius, 0, twoPi, style.fullCircleSegments),
		sectorArc = TACTICAL_STYLE.SampleGroundArc(cx, cz, sectorRange, startAngle, endAngle, style.arcSegments),
		startEdge = TACTICAL_STYLE.SampleGroundRadial(cx, cz, startAngle, sightRadius, sectorRange, style.sideLineSegments),
		endEdge = TACTICAL_STYLE.SampleGroundRadial(cx, cz, endAngle, sightRadius, sectorRange, style.sideLineSegments),
	}

	if style.drawTargetingRails then
		local railOffset = math.rad(style.targetingRailOffsetDegrees)
		geometry.targetingRails = {
			TACTICAL_STYLE.SampleGroundRadial(cx, cz, startAngle, 0, sectorRange, style.sideLineSegments),
			TACTICAL_STYLE.SampleGroundRadial(cx, cz, endAngle, 0, sectorRange, style.sideLineSegments),
			TACTICAL_STYLE.SampleGroundRadial(cx, cz, heading - railOffset, 0, sectorRange, style.sideLineSegments),
			TACTICAL_STYLE.SampleGroundRadial(cx, cz, heading + railOffset, 0, sectorRange, style.sideLineSegments),
		}
	end

	if style.drawCenterline then
		geometry.centerline = TACTICAL_STYLE.SampleGroundRadial(cx, cz, heading, 0, sectorRange, style.sideLineSegments)
	end

	if style.drawGuideArc then
		local guideRadius = sightRadius + (sectorRange - sightRadius) * 0.5
		geometry.guideArc = TACTICAL_STYLE.SampleGroundArc(cx, cz, guideRadius, startAngle, endAngle, style.arcSegments)
	end

	return geometry
end

function TACTICAL_STYLE.GetSectorGeometry(unitID, unitDefID, halfAngle, sectorRange)
	local now = TACTICAL_STYLE.GetNow()
	local cached = TACTICAL_STYLE.sectorGeometryCache[unitID]
	if cached
		and cached.unitDefID == unitDefID
		and cached.halfAngle == halfAngle
		and cached.sectorRange == max(TACTICAL_STYLE.sightRadius + 1, sectorRange)
		and TACTICAL_STYLE.CacheIsFresh(cached, now)
	then
		return cached
	end

	local geometry = TACTICAL_STYLE.BuildSectorGeometry(unitID, unitDefID, halfAngle, sectorRange, now)
	TACTICAL_STYLE.sectorGeometryCache[unitID] = geometry
	return geometry
end

function TACTICAL_STYLE.DrawSelectedSector(unitID, unitDefID, halfAngle, sectorRange)
	local geometry = TACTICAL_STYLE.GetSectorGeometry(unitID, unitDefID, halfAngle, sectorRange)
	if not geometry then
		return
	end

	local style = TACTICAL_STYLE.sector
	local alphaScale = TACTICAL_STYLE.GetZoomAlphaScale(geometry.cx, geometry.groundY, geometry.cz)

	-- r21 deliberately drops the old wide glow strips. Crisp terrain-draped lines
	-- remain, while radar keeps its translucent diffusion band.
	TACTICAL_STYLE.DrawSampledLine(geometry.sightArc, style.sightColor, style.sightRingAlpha * alphaScale, style.coreLineWidth)
	TACTICAL_STYLE.DrawSampledLine(geometry.sectorArc, style.color, style.outerArcAlpha * alphaScale, style.coreLineWidth)
	TACTICAL_STYLE.DrawSampledLine(geometry.startEdge, style.color, style.edgeAlpha * alphaScale, style.coreLineWidth)
	TACTICAL_STYLE.DrawSampledLine(geometry.endEdge, style.color, style.edgeAlpha * alphaScale, style.coreLineWidth)

	if geometry.targetingRails then
		TACTICAL_STYLE.DrawSampledLine(geometry.targetingRails[1], style.color, style.targetingRailAlpha * 0.90 * alphaScale, style.targetingRailWidth)
		TACTICAL_STYLE.DrawSampledLine(geometry.targetingRails[2], style.color, style.targetingRailAlpha * 0.90 * alphaScale, style.targetingRailWidth)
		TACTICAL_STYLE.DrawSampledLine(geometry.targetingRails[3], style.color, style.targetingRailAlpha * alphaScale, style.targetingRailWidth)
		TACTICAL_STYLE.DrawSampledLine(geometry.targetingRails[4], style.color, style.targetingRailAlpha * alphaScale, style.targetingRailWidth)
	end

	if geometry.centerline then
		gl.LineStipple(2, 0xAAAA)
		TACTICAL_STYLE.DrawSampledLine(geometry.centerline, style.color, style.centerlineAlpha * alphaScale, 1.0)
		gl.LineStipple(false)
	end

	if geometry.guideArc then
		TACTICAL_STYLE.DrawSampledLine(geometry.guideArc, style.color, style.guideArcAlpha * alphaScale, 1.0)
	end
end

function TACTICAL_STYLE.GetLiveRadarRadius(unitID, unitDefID)
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

function TACTICAL_STYLE.BuildRadarSources(selectedUnitsSorted)
	local sources = {}

	for unitDefID, units in pairs(selectedUnitsSorted) do
		for i = 1, #units do
			local unitID = units[i]
			if Spring.GetUnitDefID(unitID) == unitDefID then
				local transported = Spring.GetUnitTransporter and Spring.GetUnitTransporter(unitID)
				local active = not Spring.GetUnitIsActive or Spring.GetUnitIsActive(unitID)

				if not transported and active then
					local radius = TACTICAL_STYLE.GetLiveRadarRadius(unitID, unitDefID)
					if radius > 0 then
						local x, y, z = Spring.GetUnitPosition(unitID)
						if x then
							sources[#sources + 1] = {
								unitID = unitID,
								x = x,
								z = z,
								y = GetGroundHeight(x, z),
								radius = radius,
							}
						end
					end
				end
			end
		end
	end

	return sources
end

function TACTICAL_STYLE.GetExposedArcs(sourceIndex, sources)
	local source = sources[sourceIndex]
	local covered = {}
	local epsilon = 0.001
	local twoPi = 2 * pi

	for otherIndex = 1, #sources do
		if otherIndex ~= sourceIndex then
			local other = sources[otherIndex]
			local dx = other.x - source.x
			local dz = other.z - source.z
			local d2 = dx * dx + dz * dz
			local d = sqrt(d2)

			if d <= epsilon then
				if other.radius > source.radius + epsilon then
					return {}
				elseif math.abs(other.radius - source.radius) <= epsilon and otherIndex < sourceIndex then
					return {}
				end
			elseif d + source.radius <= other.radius + epsilon then
				return {}
			elseif d < source.radius + other.radius - epsilon and d + other.radius > source.radius + epsilon then
				local c = (source.radius * source.radius + d2 - other.radius * other.radius) / (2 * source.radius * d)
				c = max(-1, min(1, c))
				local half = math.acos(c)
				local center = math.atan2(dx, dz)

				while center < 0 do
					center = center + twoPi
				end
				while center >= twoPi do
					center = center - twoPi
				end

				local a0 = center - half
				local a1 = center + half

				if a0 < 0 then
					covered[#covered + 1] = {0, a1}
					covered[#covered + 1] = {a0 + twoPi, twoPi}
				elseif a1 > twoPi then
					covered[#covered + 1] = {a0, twoPi}
					covered[#covered + 1] = {0, a1 - twoPi}
				else
					covered[#covered + 1] = {a0, a1}
				end
			end
		end
	end

	if #covered == 0 then
		return {{0, twoPi}}
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

	if cursor < twoPi - epsilon then
		exposed[#exposed + 1] = {cursor, twoPi}
	end

	return exposed
end

function TACTICAL_STYLE.GetSelectionKey(selectedUnitsSorted)
	local ids = {}
	for _, units in pairs(selectedUnitsSorted) do
		for i = 1, #units do
			ids[#ids + 1] = units[i]
		end
	end
	table.sort(ids)
	return table.concat(ids, ",")
end

function TACTICAL_STYLE.BuildRadarGeometry(selectedUnitsSorted, selectionKey, now)
	local style = TACTICAL_STYLE.radar
	local sources = TACTICAL_STYLE.BuildRadarSources(selectedUnitsSorted)
	local multiSource = #sources > 1
	local ringSegments = multiSource and style.multiRingSegments or style.ringSegments
	local radialSteps = multiSource and style.multiRadialSteps or style.radialSteps

	for sourceIndex = 1, #sources do
		local source = sources[sourceIndex]
		source.arcs = {}
		local arcs = TACTICAL_STYLE.GetExposedArcs(sourceIndex, sources)

		for arcIndex = 1, #arcs do
			local a0 = arcs[arcIndex][1]
			local a1 = arcs[arcIndex][2]
			local segments = max(2, math.ceil(ringSegments * ((a1 - a0) / (2 * pi))))
			local arcCache = {}
			local innerRadius = max(0, source.radius - style.diffuseWidth)
			local span = max(1, source.radius - innerRadius)
			local rows = {}

			for radial = 0, radialSteps - 1 do
				local t0 = radial / radialSteps
				local t1 = (radial + 1) / radialSteps
				local r0 = innerRadius + span * t0
				local r1 = innerRadius + span * t1
				rows[#rows + 1] = {
					t0 = t0,
					t1 = t1,
					row0 = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, r0, a0, a1, segments, arcCache),
					row1 = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, r1, a0, a1, segments, arcCache),
				}
			end

			source.arcs[#source.arcs + 1] = {
				a0 = a0,
				a1 = a1,
				rows = rows,
				boundary = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, source.radius, a0, a1, segments, arcCache),
			}
		end
	end

	return {
		timestamp = now,
		selectionKey = selectionKey,
		sources = sources,
		ringSegments = ringSegments,
		radialSteps = radialSteps,
	}
end

function TACTICAL_STYLE.GetRadarGeometry(selectedUnitsSorted)
	local selectionKey = TACTICAL_STYLE.GetSelectionKey(selectedUnitsSorted)
	local now = TACTICAL_STYLE.GetNow()
	local cached = TACTICAL_STYLE.radarGeometryCache

	if cached
		and cached.selectionKey == selectionKey
		and TACTICAL_STYLE.CacheIsFresh(cached, now)
	then
		return cached
	end

	cached = TACTICAL_STYLE.BuildRadarGeometry(selectedUnitsSorted, selectionKey, now)
	TACTICAL_STYLE.radarGeometryCache = cached
	return cached
end

function TACTICAL_STYLE.DrawRadarWorldUnion(selectedUnitsSorted)
	if not TACTICAL_STYLE.drawRadar then
		return
	end

	local style = TACTICAL_STYLE.radar
	local geometry = TACTICAL_STYLE.GetRadarGeometry(selectedUnitsSorted)
	if not geometry then
		return
	end

	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	for sourceIndex = 1, #geometry.sources do
		local source = geometry.sources[sourceIndex]
		local alphaScale = TACTICAL_STYLE.GetZoomAlphaScale(source.x, source.y, source.z)

		for arcIndex = 1, #source.arcs do
			local arc = source.arcs[arcIndex]
			for rowIndex = 1, #arc.rows do
				local row = arc.rows[rowIndex]
				local a0 = (style.diffuseInnerAlpha + (style.diffuseEdgeAlpha - style.diffuseInnerAlpha) * row.t0) * alphaScale
				local a1 = (style.diffuseInnerAlpha + (style.diffuseEdgeAlpha - style.diffuseInnerAlpha) * row.t1) * alphaScale
				gl.BeginEnd(GL.TRIANGLE_STRIP, function()
					for i = 1, #row.row0, 3 do
						gl.Color(style.color[1], style.color[2], style.color[3], a0)
						gl.Vertex(row.row0[i], row.row0[i + 1], row.row0[i + 2])
						gl.Color(style.color[1], style.color[2], style.color[3], a1)
						gl.Vertex(row.row1[i], row.row1[i + 1], row.row1[i + 2])
					end
				end)
			end

			TACTICAL_STYLE.DrawSampledLine(arc.boundary, style.color, style.ringAlpha * alphaScale, style.ringWidth)
		end
	end
end

function TACTICAL_STYLE.GetLiveECMRadius(unitID, unitDefID)
	local radius = nil
	if Spring.GetUnitSensorRadius then
		radius = Spring.GetUnitSensorRadius(unitID, "radarJammer")
	end

	if radius == nil then
		local unitDef = unitDefID and UnitDefs[unitDefID]
		radius = unitDef and unitDef.jammerRadius or 0
	end

	return tonumber(radius) or 0
end

function TACTICAL_STYLE.BuildECMSources(selectedUnitsSorted)
	local sources = {}
	local sourceByID = {}
	local selected = {}

	for _, units in pairs(selectedUnitsSorted or {}) do
		for i = 1, #units do
			selected[units[i]] = true
		end
	end

	local function AddEmitter(unitID, isSelected)
		local existing = sourceByID[unitID]
		if existing then
			if isSelected then
				existing.selected = true
			end
			return
		end

		local unitDefID = Spring.GetUnitDefID(unitID)
		if not unitDefID or not TACTICAL_STYLE.ecmCapableUnitDefs[unitDefID] then
			return
		end

		local transported = Spring.GetUnitTransporter and Spring.GetUnitTransporter(unitID)
		local active = not Spring.GetUnitIsActive or Spring.GetUnitIsActive(unitID)
		if transported or not active then
			return
		end

		local radius = TACTICAL_STYLE.GetLiveECMRadius(unitID, unitDefID)
		if radius <= 16 then
			return
		end

		local x, y, z = Spring.GetUnitPosition(unitID)
		if not x then
			return
		end

		local source = {
			unitID = unitID,
			unitDefID = unitDefID,
			x = x,
			z = z,
			y = GetGroundHeight(x, z),
			radius = radius,
			selected = isSelected == true,
		}
		sources[#sources + 1] = source
		sourceByID[unitID] = source
	end

	-- Ambient ECM exists only for emitters currently in the camera field of view.
	-- icons=false excludes strategic/radar icons so hidden or icon-only contacts do
	-- not gain a world-space ECM field. Friendly, enemy and neutral units are all
	-- eligible when the engine actually renders the unit.
	if Spring.GetVisibleUnits then
		local visibleUnits = Spring.GetVisibleUnits(-1, 0, false) or {}
		for i = 1, #visibleUnits do
			local unitID = visibleUnits[i]
			AddEmitter(unitID, selected[unitID] == true)
		end
	end

	-- A selected emitter retains the full r28 presentation even if the camera has
	-- moved far enough that GetVisibleUnits no longer includes the unit itself.
	for unitID in pairs(selected) do
		AddEmitter(unitID, true)
	end

	table.sort(sources, function(a, b)
		return a.unitID < b.unitID
	end)
	return sources
end

function TACTICAL_STYLE.BuildECMGeometry(selectedUnitsSorted, selectionKey, now)
	local sources = TACTICAL_STYLE.BuildECMSources(selectedUnitsSorted)
	local twoPi = 2 * pi
	local selectedSources = {}

	for sourceIndex = 1, #sources do
		local source = sources[sourceIndex]
		source.phase = (source.unitID * 0.7548776662466927) % twoPi
		if source.selected then
			selectedSources[#selectedSources + 1] = source
		end

		-- Selected emitters retain the r28 quality tier. Ambient emitters use a
		-- deliberately cheaper mesh because several can be visible simultaneously.
		local fieldSegments = source.selected and 48 or 28
		local fieldRadialSteps = source.selected and 10 or 6
		local perimeterRadialSteps = source.selected and 3 or 2

		source.fieldRows = {}
		local arcCache = {}
		for radial = 0, fieldRadialSteps - 1 do
			local t0 = radial / fieldRadialSteps
			local t1 = (radial + 1) / fieldRadialSteps
			source.fieldRows[#source.fieldRows + 1] = {
				t0 = t0,
				t1 = t1,
				row0 = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, source.radius * t0, 0, twoPi, fieldSegments, arcCache),
				row1 = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, source.radius * t1, 0, twoPi, fieldSegments, arcCache),
			}
		end

		source.perimeterRows = {}
		local perimeterInner = 0.86
		local perimeterOuter = 1.05
		local perimeterSpan = perimeterOuter - perimeterInner
		for radial = 0, perimeterRadialSteps - 1 do
			local t0 = perimeterInner + perimeterSpan * (radial / perimeterRadialSteps)
			local t1 = perimeterInner + perimeterSpan * ((radial + 1) / perimeterRadialSteps)
			source.perimeterRows[#source.perimeterRows + 1] = {
				t0 = t0,
				t1 = t1,
				row0 = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, source.radius * t0, 0, twoPi, fieldSegments, arcCache),
				row1 = TACTICAL_STYLE.SampleGroundArc(source.x, source.z, source.radius * t1, 0, twoPi, fieldSegments, arcCache),
			}
		end
	end

	-- The minimap ECM perimeter remains selected-unit-only, exactly as before r29.
	for sourceIndex = 1, #selectedSources do
		local source = selectedSources[sourceIndex]
		source.arcs = {}
		local arcs = TACTICAL_STYLE.GetExposedArcs(sourceIndex, selectedSources)
		for arcIndex = 1, #arcs do
			source.arcs[#source.arcs + 1] = {a0 = arcs[arcIndex][1], a1 = arcs[arcIndex][2]}
		end
	end

	return {
		timestamp = now,
		selectionKey = selectionKey,
		sources = sources,
	}
end

function TACTICAL_STYLE.GetECMGeometry(selectedUnitsSorted)
	local selectionKey = TACTICAL_STYLE.GetSelectionKey(selectedUnitsSorted)
	local now = TACTICAL_STYLE.GetNow()
	local cached = TACTICAL_STYLE.ecmGeometryCache

	if cached and cached.selectionKey == selectionKey and cached.timestamp ~= nil then
		local age
		if Spring.DiffTimers and (Spring.GetFrameTimer or Spring.GetTimer) then
			age = Spring.DiffTimers(now, cached.timestamp)
		else
			age = now - cached.timestamp
		end
		if age >= 0 and age < (1 / 15) then
			return cached
		end
	end

	cached = TACTICAL_STYLE.BuildECMGeometry(selectedUnitsSorted, selectionKey, now)
	TACTICAL_STYLE.ecmGeometryCache = cached
	return cached
end

function TACTICAL_STYLE.GetECMAnimationTime()
	if Spring.GetGameSecondsInterpolated then
		return Spring.GetGameSecondsInterpolated()
	elseif Spring.GetGameSeconds then
		return Spring.GetGameSeconds()
	end
	return 0
end

function TACTICAL_STYLE.Smoothstep(edge0, edge1, value)
	if edge1 <= edge0 then
		return value >= edge1 and 1 or 0
	end
	local t = TACTICAL_STYLE.Clamp01((value - edge0) / (edge1 - edge0))
	return t * t * (3 - 2 * t)
end

function TACTICAL_STYLE.GetECMFieldVertex(source, x, z, radial, now, alphaScale)
	local color = TACTICAL_STYLE.ecm.color
	local phase = source.phase or 0
	local selected = source.selected == true

	local n1 = 0.5 + 0.5 * sin(x * 0.018 + z * 0.009 + now * 0.35 + phase)
	local n2 = 0.5 + 0.5 * sin(x * -0.011 + z * 0.021 - now * 0.27 + phase * 1.37)
	local n3 = 0.5 + 0.5 * sin((x + z) * 0.0065 + now * 0.18 + phase * 0.61)
	local noise = n1 * 0.45 + n2 * 0.35 + n3 * 0.20
	local patch = TACTICAL_STYLE.Smoothstep(0.31, 0.64, noise)
	local patchAlpha = (selected and 0.08 or 0.05) + (selected and 0.92 or 0.95) * patch

	local dx = x - source.x
	local dz = z - source.z
	local angle = math.atan2(dz, dx)
	local currentWarp = sin(radial * 7.0 - now * 0.2645 + phase * 0.73) * 0.85
	local currentWave = 0.5 + 0.5 * sin(angle * 5.0 + radial * 16.0 + currentWarp - now * 1.15 + phase)
	local current = TACTICAL_STYLE.Smoothstep(0.68, 0.91, currentWave)

	local s1 = 0.5 + 0.5 * sin(x * 0.046 + z * -0.031 + now * 1.334 + phase * 1.91)
	local s2 = 0.5 + 0.5 * sin(x * -0.057 + z * 0.041 - now * 1.0295 + phase * 0.43)
	local s3 = 0.5 + 0.5 * sin((x - z) * 0.034 + now * 1.6385 + phase * 1.27)
	local stormNoise = (s1 * s2) * 0.62 + s3 * 0.38
	local storm = TACTICAL_STYLE.Smoothstep(0.42, 0.72, stormNoise)
	storm = storm * (0.72 + 0.28 * sin(now * 3.2 + x * 0.012 + z * 0.009 + phase))

	local edgePosition = 1 + (noise - 0.5) * 0.20
	local edgeAlpha = 1 - TACTICAL_STYLE.Smoothstep(edgePosition - 0.22, edgePosition, radial)

	-- r29 ping: the same expanding front as r28, but 4.2 s -> 2.8 s.
	-- Crossing the same radius in two thirds the time is approximately 50% faster.
	local pulsePeriod = 2.8
	local pulseOffset = (phase / (2 * pi)) * pulsePeriod
	local pulsePosition = ((now + pulseOffset) % pulsePeriod) / pulsePeriod
	local pulseDistance = math.abs(radial - pulsePosition)
	local pulse = 1 - TACTICAL_STYLE.Smoothstep(0.03675, 0.105, pulseDistance)
	pulse = pulse * (1 - 0.72 * TACTICAL_STYLE.Smoothstep(0.78, 1.0, pulsePosition))

	-- Unselected visible emitters retain the storm/perimeter/pulse language but
	-- suppress most of the strong current contribution and cap opacity heavily.
	local currentStrength = selected and 0.95 or 0.28
	local stormStrength = selected and 0.90 or 0.52
	local fieldAlpha = selected and 0.14 or 0.055
	local maxFieldAlpha = selected and 0.32 or 0.13
	local pulseAlpha = selected and 0.15 or 0.070
	local pulseBrightness = selected and 0.46 or 0.24

	local activity = 1 + current * currentStrength + storm * stormStrength
	local alpha = min(maxFieldAlpha, fieldAlpha * patchAlpha * activity + pulse * pulseAlpha) * edgeAlpha * alphaScale
	local brightness = 0.72 + noise * 0.24 + current * (selected and 0.31 or 0.12) + storm * (selected and 0.25 or 0.18) + pulse * pulseBrightness

	return
		min(1, color[1] * brightness),
		min(1, color[2] * brightness),
		min(1, color[3] * brightness),
		alpha
end


function TACTICAL_STYLE.GetECMPerimeterVertex(source, x, z, radial, now, alphaScale)
	local color = TACTICAL_STYLE.ecm.color
	local phase = source.phase or 0
	local selected = source.selected == true
	local dx = x - source.x
	local dz = z - source.z
	local angle = math.atan2(dz, dx)

	local p1 = 0.5 + 0.5 * sin(angle * 7.0 + now * 0.72 + phase + sin(angle * 3.0 - now * 0.31 + phase * 0.4) * 0.9)
	local p2 = 0.5 + 0.5 * sin(angle * -11.0 + now * 0.3096 + phase * 1.73)
	local breakup = p1 * 0.68 + p2 * 0.32
	local disturbance = TACTICAL_STYLE.Smoothstep(0.38, 0.70, breakup)

	local centre = 1 + sin(angle * 5.0 - now * 0.19 + phase) * 0.025 + sin(angle * 9.0 + now * 0.13 + phase * 0.6) * 0.012
	local distance = math.abs(radial - centre)
	local haze = 1 - TACTICAL_STYLE.Smoothstep(0.0266, 0.095, distance)

	local pulsePeriod = 2.8
	local pulseOffset = (phase / (2 * pi)) * pulsePeriod
	local pulsePosition = ((now + pulseOffset) % pulsePeriod) / pulsePeriod
	local arrival = TACTICAL_STYLE.Smoothstep(0.76, 0.98, pulsePosition)

	local perimeterAlpha = selected and 0.16 or 0.065
	local alpha = perimeterAlpha * haze * (0.28 + disturbance * 0.72) * (1 + arrival * 0.38) * alphaScale
	local brightness = 0.90 + disturbance * (selected and 0.36 or 0.24) + arrival * (selected and 0.20 or 0.12)

	return
		min(1, color[1] * brightness),
		min(1, color[2] * brightness),
		min(1, color[3] * brightness),
		alpha
end

function TACTICAL_STYLE.RefreshECMVisualCache(source, now, alphaScale)
	local last = source.visualCacheTime
	local refreshSeconds = source.selected and (1 / 15) or (1 / 10)
	if last ~= nil and (now - last) >= 0 and (now - last) < refreshSeconds then
		return
	end

	source.visualCacheTime = now
	source.fieldColors = source.fieldColors or {}
	source.perimeterColors = source.perimeterColors or {}

	for rowIndex = 1, #source.fieldRows do
		local row = source.fieldRows[rowIndex]
		local colors = source.fieldColors[rowIndex] or {}
		source.fieldColors[rowIndex] = colors
		for i = 1, #row.row0, 3 do
			local ci = ((i - 1) / 3) * 8 + 1
			local r0, g0, b0, a0 =
				TACTICAL_STYLE.GetECMFieldVertex(
					source,
					row.row0[i],
					row.row0[i + 2],
					row.t0,
					now,
					alphaScale
				)
			colors[ci] = r0
			colors[ci + 1] = g0
			colors[ci + 2] = b0
			colors[ci + 3] = a0

			local r1, g1, b1, a1 =
				TACTICAL_STYLE.GetECMFieldVertex(
					source,
					row.row1[i],
					row.row1[i + 2],
					row.t1,
					now,
					alphaScale
				)
			colors[ci + 4] = r1
			colors[ci + 5] = g1
			colors[ci + 6] = b1
			colors[ci + 7] = a1
		end
	end

	for rowIndex = 1, #source.perimeterRows do
		local row = source.perimeterRows[rowIndex]
		local colors = source.perimeterColors[rowIndex] or {}
		source.perimeterColors[rowIndex] = colors
		for i = 1, #row.row0, 3 do
			local ci = ((i - 1) / 3) * 8 + 1
			local r0, g0, b0, a0 =
				TACTICAL_STYLE.GetECMPerimeterVertex(
					source,
					row.row0[i],
					row.row0[i + 2],
					row.t0,
					now,
					alphaScale
				)
			colors[ci] = r0
			colors[ci + 1] = g0
			colors[ci + 2] = b0
			colors[ci + 3] = a0

			local r1, g1, b1, a1 =
				TACTICAL_STYLE.GetECMPerimeterVertex(
					source,
					row.row1[i],
					row.row1[i + 2],
					row.t1,
					now,
					alphaScale
				)
			colors[ci + 4] = r1
			colors[ci + 5] = g1
			colors[ci + 6] = b1
			colors[ci + 7] = a1
		end
	end
end

function TACTICAL_STYLE.DrawECMWorldUnion(selectedUnitsSorted)
	if not TACTICAL_STYLE.drawECM then
		return
	end

	local geometry = TACTICAL_STYLE.GetECMGeometry(selectedUnitsSorted)
	if not geometry then
		return
	end

	local now = TACTICAL_STYLE.GetECMAnimationTime()
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	for sourceIndex = 1, #geometry.sources do
		local source = geometry.sources[sourceIndex]
		local alphaScale = TACTICAL_STYLE.GetZoomAlphaScale(source.x, source.y, source.z)
		TACTICAL_STYLE.RefreshECMVisualCache(source, now, alphaScale)

		for rowIndex = 1, #source.fieldRows do
			local row = source.fieldRows[rowIndex]
			local colors = source.fieldColors[rowIndex]
			gl.BeginEnd(GL.TRIANGLE_STRIP, function()
				for i = 1, #row.row0, 3 do
					local ci = ((i - 1) / 3) * 8 + 1
					gl.Color(colors[ci], colors[ci + 1], colors[ci + 2], colors[ci + 3])
					gl.Vertex(row.row0[i], row.row0[i + 1], row.row0[i + 2])
					gl.Color(colors[ci + 4], colors[ci + 5], colors[ci + 6], colors[ci + 7])
					gl.Vertex(row.row1[i], row.row1[i + 1], row.row1[i + 2])
				end
			end)
		end

		for rowIndex = 1, #source.perimeterRows do
			local row = source.perimeterRows[rowIndex]
			local colors = source.perimeterColors[rowIndex]
			gl.BeginEnd(GL.TRIANGLE_STRIP, function()
				for i = 1, #row.row0, 3 do
					local ci = ((i - 1) / 3) * 8 + 1
					gl.Color(colors[ci], colors[ci + 1], colors[ci + 2], colors[ci + 3])
					gl.Vertex(row.row0[i], row.row0[i + 1], row.row0[i + 2])
					gl.Color(colors[ci + 4], colors[ci + 5], colors[ci + 6], colors[ci + 7])
					gl.Vertex(row.row1[i], row.row1[i + 1], row.row1[i + 2])
				end
			end)
		end
	end

	gl.Color(1, 1, 1, 1)
end

function TACTICAL_STYLE.ApplyMiniMapTransform(sx, sy)
	local rotation = Spring.GetMiniMapRotation and Spring.GetMiniMapRotation() or 0
	if math.abs(rotation) > 1.5 then
		gl.Translate(sx, 0, 0)
		gl.Scale(-sx / Game.mapSizeX, sy / Game.mapSizeZ, 1)
	else
		gl.Translate(0, sy, 0)
		gl.Scale(sx / Game.mapSizeX, -sy / Game.mapSizeZ, 1)
	end
end

function TACTICAL_STYLE.DrawMiniMapArcLine(source, startAngle, endAngle, alpha, width)
	local style = TACTICAL_STYLE.radar
	local segments = max(2, math.ceil(style.miniMapSegments * ((endAngle - startAngle) / (2 * pi))))
	gl.Color(style.color[1], style.color[2], style.color[3], alpha)
	gl.LineWidth(width)
	gl.BeginEnd(GL.LINE_STRIP, function()
		for i = 0, segments do
			local t = i / segments
			local angle = startAngle + (endAngle - startAngle) * t
			gl.Vertex(source.x + sin(angle) * source.radius, source.z + cos(angle) * source.radius, 0)
		end
	end)
end

function TACTICAL_STYLE.DrawRadarMiniMapUnion(selectedUnitsSorted, sx, sy)
	if not TACTICAL_STYLE.drawRadar then
		return
	end

	-- Reuse the same cached source positions and exposed-union arcs as DrawWorld.
	-- The minimap itself stays deliberately simple: one crisp green perimeter only.
	local style = TACTICAL_STYLE.radar
	local geometry = TACTICAL_STYLE.GetRadarGeometry(selectedUnitsSorted)
	if not geometry or #geometry.sources == 0 then
		return
	end

	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.PushMatrix()
	TACTICAL_STYLE.ApplyMiniMapTransform(sx, sy)

	for sourceIndex = 1, #geometry.sources do
		local source = geometry.sources[sourceIndex]
		for arcIndex = 1, #source.arcs do
			local arc = source.arcs[arcIndex]
			TACTICAL_STYLE.DrawMiniMapArcLine(source, arc.a0, arc.a1, style.ringAlpha, style.ringWidth)
		end
	end

	gl.PopMatrix()
	gl.Texture(false)
	gl.LineWidth(1)
	gl.Color(1, 1, 1, 1)
	if gl.PopAttrib then
		gl.PopAttrib()
	end
end

function TACTICAL_STYLE.DrawECMMiniMapArcLine(source, startAngle, endAngle, alpha, width)
	local color = TACTICAL_STYLE.ecm.color
	local segments = max(2, math.ceil(64 * ((endAngle - startAngle) / (2 * pi))))
	gl.Color(color[1], color[2], color[3], alpha)
	gl.LineWidth(width)
	gl.BeginEnd(GL.LINE_STRIP, function()
		for i = 0, segments do
			local t = i / segments
			local angle = startAngle + (endAngle - startAngle) * t
			gl.Vertex(source.x + sin(angle) * source.radius, source.z + cos(angle) * source.radius, 0)
		end
	end)
end

function TACTICAL_STYLE.DrawECMMiniMapUnion(selectedUnitsSorted, sx, sy)
	if not TACTICAL_STYLE.drawECM then
		return
	end

	local geometry = TACTICAL_STYLE.GetECMGeometry(selectedUnitsSorted)
	if not geometry or #geometry.sources == 0 then
		return
	end

	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.PushMatrix()
	TACTICAL_STYLE.ApplyMiniMapTransform(sx, sy)

	for sourceIndex = 1, #geometry.sources do
		local source = geometry.sources[sourceIndex]
		if source.selected and source.arcs then
			for arcIndex = 1, #source.arcs do
				local arc = source.arcs[arcIndex]
				TACTICAL_STYLE.DrawECMMiniMapArcLine(source, arc.a0, arc.a1, 0.68, 1.7)
			end
		end
	end

	gl.PopMatrix()
	gl.Texture(false)
	gl.LineWidth(1)
	gl.Color(1, 1, 1, 1)
	if gl.PopAttrib then
		gl.PopAttrib()
	end
end

function TACTICAL_STYLE.Initialize()
	for unitDefID, unitDef in ipairs(UnitDefs) do
		if (tonumber(unitDef.jammerRadius) or 0) > 0 then
			TACTICAL_STYLE.ecmCapableUnitDefs[unitDefID] = true
		end

		local halfAngle = TACTICAL_STYLE.GetUnitDefHalfAngle(unitDef)
		if halfAngle then
			TACTICAL_STYLE.unitDefInfos[unitDefID] = {
				halfAngle = halfAngle,
			}
		end
	end
end

function TACTICAL_STYLE.DrawECMEnvironmentWorld()
	if not TACTICAL_STYLE.drawECM then
		return
	end
	if Spring.IsGUIHidden and Spring.IsGUIHidden() then
		return
	end

	local selectedUnitsSorted = Spring.GetSelectedUnitsSorted and Spring.GetSelectedUnitsSorted()
	if not selectedUnitsSorted then
		return
	end

	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	TACTICAL_STYLE.DrawECMWorldUnion(selectedUnitsSorted)

	gl.Color(1, 1, 1, 1)
	if gl.PopAttrib then
		gl.PopAttrib()
	else
		gl.DepthMask(true)
		gl.DepthTest(false)
		gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	end
end

function TACTICAL_STYLE.DrawWorld()
	if Spring.IsGUIHidden and Spring.IsGUIHidden() then
		return
	end

	local selectedUnitsSorted = Spring.GetSelectedUnitsSorted and Spring.GetSelectedUnitsSorted()
	if not selectedUnitsSorted then
		return
	end

	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	TACTICAL_STYLE.DrawRadarWorldUnion(selectedUnitsSorted)

	if TACTICAL_STYLE.drawSector then
		for unitDefID, info in pairs(TACTICAL_STYLE.unitDefInfos) do
			local units = selectedUnitsSorted[unitDefID]
			if units then
				for i = 1, #units do
					local unitID = units[i]
					local transported = Spring.GetUnitTransporter and Spring.GetUnitTransporter(unitID)
					if not transported and Spring.GetUnitDefID(unitID) then
						local sectorRange =
							(Spring.GetUnitRulesParam(unitID, "sectorradius") or TACTICAL_STYLE.sectorFallback)
							- TACTICAL_STYLE.sectorInset

						TACTICAL_STYLE.DrawSelectedSector(unitID, unitDefID, info.halfAngle, sectorRange)
					end
				end
			end
		end
	end

	gl.LineStipple(false)
	gl.LineWidth(1)
	gl.Texture(false)
	gl.Color(1, 1, 1, 1)
	if gl.PopAttrib then
		gl.PopAttrib()
	else
		gl.DepthMask(true)
		gl.DepthTest(false)
		gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	end
end

function widget:Initialize()
	TACTICAL_STYLE.Initialize()
	-- Change default command menu font
	local currentFont = Spring.GetConfigString("FontFile")
	local currentFontSmall = Spring.GetConfigString("SmallFontFile")
	Spring.SendCommands("font HandelGothic.ttf")
	Spring.SetConfigString("FontFile", currentFont)
	Spring.SetConfigString("SmallFontFile", currentFontSmall)
	-- Cache ranges
	for unitDefID, unitDef in pairs(UnitDefs) do
		local weapons = unitDef.weapons
		local weaponTypes = {}
		local mech = unitDef.customParams.baseclass == "mech"
		weaponRanges[unitDefID] = {}
		for i = 1, #weapons - (mech and 1 or 0) do -- cut off sight weapon for mechs
			local weaponDef = WeaponDefs[weapons[i].weaponDef]
			weaponTypes[weaponDef.name] = weaponDef.range
			local minRange = tonumber(weaponDef.customParams.minrange) or nil
			weaponRanges[unitDefID][#weaponRanges[unitDefID] + 1] = {
				weaponNum = i,
				name = weaponDef.name,
				maxRange = weaponDef.range,
				minRange = minRange,
				textColour = weaponDef.customParams.textcolour or "",
			}
			if minRange then
				if not minRanges[unitDefID] then
					minRanges[unitDefID] = {}
				end
				minRanges[unitDefID][weaponDef.name] = minRange
			end
		end
		maxRanges[unitDefID] = weaponTypes
		local salvageRange = unitDef.customParams.salvagerange or nil
		if salvageRange then
			salvageRanges[unitDefID] = salvageRange
		end
		-- now loop over min and max and build the strings
		maxRangesToDraw[unitDefID] = {}
		minRangesToDraw[unitDefID] = {}
		for name, range in pairs(maxRanges[unitDefID]) do
			if not maxRangesToDraw[unitDefID][range] then
				maxRangesToDraw[unitDefID][range] = "Max Range: " .. (WeaponDefNames[name].customParams.textcolour or "") .. name
			else
				maxRangesToDraw[unitDefID][range] = maxRangesToDraw[unitDefID][range] .. ", " .. WeaponDefNames[name].customParams.textcolour.. name
			end
			local minRangeDef = minRanges[unitDefID]
			local minRange = minRangeDef and minRangeDef[name] or nil
				
			if minRange then
				if not minRangesToDraw[unitDefID][minRange] then
					minRangesToDraw[unitDefID][minRange] = "Min Range: " .. WeaponDefNames[name].customParams.textcolour .. name
				else
					minRangesToDraw[unitDefID][minRange] = minRangesToDraw[unitDefID][minRange] .. ", " .. WeaponDefNames[name].customParams.textcolour .. name
				end				
			end
		end
	end
	-- Setup fonts for drawing
	btFont = gl.LoadFont("LuaUI/Fonts/bt_oldstyle.ttf", 24, 2, 30)

	-- Suppress Recoil's built-in selected-unit maximum attack-range circle.
	-- Our active-weapon-aware rings replace it completely.
	if LoadCmdColorsConfig then
		pcall(LoadCmdColorsConfig, "rangeAttack 1.0 0.3 0.3 0.0")
	end

	local ok, initialized = pcall(InitializeGL4RingRenderer)
	ringGL4Ready = ok and initialized == true
	if ringGL4Ready then
		if diffusionGL4Ready then
			Spring.Echo("[MCL Range Rings] GL4 ring renderer active; GL4 diffusion active.")
		else
			Spring.Echo("[MCL Range Rings] GL4 ring renderer active; diffusion using legacy fallback.")
		end
	else
		Spring.Echo("[MCL Range Rings] GL4 renderer unavailable; ring and diffusion using legacy fallback.")
	end
	Spring.Echo("[MCL Range Rings r30] r29 ECM/rendering baseline preserved; Shooter Control max/min weapon ranges now reveal smoothly only near the mouse, while normal RTS attack ranges remain fully visible.")
end

function widget:Shutdown()
	-- Restore the user's/game's configured engine command colors if this widget
	-- is unloaded or disabled.
	Spring.SendCommands("cmdcolors")

	if diffusionShader then
		diffusionShader:Finalize()
		diffusionShader = nil
	end
	if ringShader then
		ringShader:Finalize()
		ringShader = nil
	end
	if ringVAO and ringVAO.Delete then
		ringVAO:Delete()
		ringVAO = nil
	end
end

local function IsDirectControlledUnit(unitID)
	local shooter =
		WG
		and WG.MCLShooterControl

	if
		not shooter
		or not shooter.IsControlledUnit
	then
		return false
	end

	local ok, result =
		pcall(
			shooter.IsControlledUnit,
			unitID
		)

	return
		ok
		and result == true
end

local function ShouldDrawWeaponRanges(unitID, directControlled)
	if
		select(
			2,
			GetActiveCommand()
		) == CMD.ATTACK
	then
		return true
	end

	return directControlled == true
end

local function GetShooterRangeMousePosition()
	if not Spring.GetMouseState or not Spring.TraceScreenRay then
		return nil
	end

	local mx, my = Spring.GetMouseState()
	if not mx then
		return nil
	end

	local _, coords = Spring.TraceScreenRay(mx, my, true)
	if type(coords) ~= "table" or not coords[1] or not coords[3] then
		return nil
	end

	return coords[1], coords[3]
end

local function GetShooterRangeRevealAlpha(directControlled, unitX, unitZ, radius, mouseX, mouseZ)
	if not directControlled then
		return 1
	end

	if not mouseX or not mouseZ then
		return 0
	end

	local dx = mouseX - unitX
	local dz = mouseZ - unitZ
	local distanceFromBoundary = math.abs(sqrt(dx * dx + dz * dz) - radius)

	-- Shooter ranges are intentionally absent until the cursor approaches the
	-- boundary. Full visibility is reached near the line, with a broad smooth
	-- approach so the player does not need pixel-perfect cursor placement.
	return 1 - TACTICAL_STYLE.Smoothstep(55, 160, distanceFromBoundary)
end

local function GetRangeLabelSize(x, y, z)
	if not GetCameraPosition then
		return RANGE_LABEL_BASE_SIZE
	end

	local cx, cy, cz =
		GetCameraPosition()

	if not cx then
		return RANGE_LABEL_BASE_SIZE
	end

	local dx = x - cx
	local dy = y - cy
	local dz = z - cz

	local distance =
		sqrt(
			dx * dx +
			dy * dy +
			dz * dz
		)

	local size =
		RANGE_LABEL_BASE_SIZE *
		(distance / RANGE_LABEL_REFERENCE_DISTANCE)

	return
		max(
			RANGE_LABEL_MIN_SIZE,
			min(
				RANGE_LABEL_MAX_SIZE,
				size
			)
		)
end

local function DrawWorldRanges()
	-- Draw range/salvage presentation in the same late world stage as the
	-- tactical sensor HUD.  FOW and LUPS have already composited by this point.
	if gl.PushAttrib then
		gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	end
	gl.DepthTest(false)
	gl.DepthMask(false)
	gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)

	-- Resolve the Shooter cursor lazily, and at most once per rendered frame.
	-- Normal RTS attack-range drawing therefore incurs no screen-ray trace at all.
	local mouseX, mouseZ
	local mouseTraceResolved = false

	for _,unitID in ipairs(GetSelectedUnits()) do
		local unitDefID = GetUnitDefID(unitID)
		local directControlled = IsDirectControlledUnit(unitID)
		if ShouldDrawWeaponRanges(unitID, directControlled) then
			if directControlled and not mouseTraceResolved then
				mouseX, mouseZ = GetShooterRangeMousePosition()
				mouseTraceResolved = true
			end
			glColor(MAX_RANGE_RING_RGB)
			local maxRangesU, minRangesU = BuildActiveWeaponRanges(unitID, unitDefID)
			local x, y, z = GetUnitPosition(unitID)
			local labelSize = GetRangeLabelSize(x, y + 40, z)
			local ringHalfWidth = GetRangeRingHalfWidth(x, y, z)
			if maxRangesU then
				for radius, info in pairs(maxRangesU) do
					local revealAlpha = GetShooterRangeRevealAlpha(directControlled, x, z, radius, mouseX, mouseZ)
					if revealAlpha > 0.001 then
						DrawRangeRing(x, y, z, radius, MAX_RANGE_RING_RGB, false, ringHalfWidth, revealAlpha)
						gl.PushMatrix()
							glTranslate(x, y + 40, z + radius + 40)
							glBillboard()
							glColor(1, 1, 1, RANGE_LABEL_ALPHA * revealAlpha)
							btFont:Print(info, 0, 0, labelSize, "oc")
						gl.PopMatrix()
					end
				end
			end
			if minRangesU then
				for radius, info in pairs(minRangesU) do
					local revealAlpha = GetShooterRangeRevealAlpha(directControlled, x, z, radius, mouseX, mouseZ)
					if revealAlpha > 0.001 then
						DrawRangeRing(x, y, z, radius, MIN_RANGE_RING_RGB, true, ringHalfWidth, revealAlpha)
						gl.PushMatrix()
							glTranslate(x, y + 40, z + radius - 40)
							glBillboard()
							glColor(1, 1, 1, RANGE_LABEL_ALPHA * revealAlpha)
							btFont:Print(info, 0, 0, labelSize, "oc")
						gl.PopMatrix()
					end
				end
			end
		else
			rangesToDraw = salvageRanges[unitDefID]
			if rangesToDraw then
				local x, y, z = GetUnitPosition(unitID)
				glColor(SALVAGE_RANGE_RING_RGB)
				local ringHalfWidth = GetRangeRingHalfWidth(x, y, z)
				DrawRangeRing(x, y, z, rangesToDraw, SALVAGE_RANGE_RING_RGB, false, ringHalfWidth)
			end
		end
		glColor(1,1,1,1)
	end

	if gl.PopAttrib then
		gl.PopAttrib()
	else
		gl.DepthMask(true)
		gl.DepthTest(false)
		gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
	end
end

function widget:DrawWorld()
	TACTICAL_STYLE.DrawECMEnvironmentWorld()
	DrawWorldRanges()
	TACTICAL_STYLE.DrawWorld()
end

function widget:DrawInMiniMap(sx, sy)
	if Spring.IsGUIHidden and Spring.IsGUIHidden() then
		return
	end

	local selectedUnitsSorted = Spring.GetSelectedUnitsSorted and Spring.GetSelectedUnitsSorted()
	if selectedUnitsSorted then
		TACTICAL_STYLE.DrawRadarMiniMapUnion(selectedUnitsSorted, sx, sy)
		TACTICAL_STYLE.DrawECMMiniMapUnion(selectedUnitsSorted, sx, sy)
	end
end

