-- Minimum-range hazard-band revision 13
function widget:GetInfo()
  return {
    name      = "MC:L - Minimum Ranges",
    desc      = "Draws active-weapon range rings with directional diffusion, hex and minimum-range hazard bands",
    author    = "FLOZi (C. Lawrence) + zvero + ChatGPT",
    date      = "28/07/2013; direct-control/zoom/GL4 diffusion integration 2026",
    license   = "GNU GPL v2",
    layer     = 10000,
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
local glTexCoord			= gl.TexCoord
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
-- Minimum-range bands use diagonal hazard stripes instead of the hex overlay.
-- MIN_RANGE_HAZARD_ALPHA controls stripe opacity, MIN_RANGE_HAZARD_SIZE controls
-- their approximate world-space pitch, and MIN_RANGE_HAZARD_FILL controls the
-- stripe/gap duty cycle (0.5 = equal stripe and gap).
-- Ring and band alpha are automatically reduced as the camera zooms farther out.
local RING_THICKNESS = 1.5
local RING_ALPHA = 0.70
local BAND_THICKNESS = 80
local MAX_BAND_ALPHA = 0.15
local MIN_BAND_ALPHA = 0.00
local MIN_RANGE_DASH_FILL = 0.50
local HEX_PATTERN_ALPHA = 0.30
local HEX_PATTERN_SIZE = 160
local MIN_RANGE_HAZARD_ALPHA = 0.45
local MIN_RANGE_HAZARD_SIZE = 48
local MIN_RANGE_HAZARD_FILL = 0.50

-- Renderer internals
local RING_SEGMENTS = 384
local RING_HEIGHT_OFFSET = 4
local RING_HEX_WORLD_SCALE = 1 / 256
local LEGACY_RING_SEGMENTS = 96
local LEGACY_DIFFUSE_STEPS = 48
local LEGACY_HEX_SEGMENTS = 192
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
local ringHexTexture = (VFS and VFS.FileExists and VFS.FileExists("bitmaps/maphex.png")) and "bitmaps/maphex.png" or false

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
in vec2 vWorldXZ;

uniform vec4 diffusionColor;
uniform sampler2D hexTex;
uniform float minBandAlpha;
uniform float hexScale;
uniform float hexPatternAlpha;
uniform int useHexTex;
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

    float hexLine = 0.0;
    if (useHexTex != 0) {
        // fract() guarantees world-space tiling even if the source bitmap was
        // loaded with clamped sampler state.
        vec2 hexUV = fract(vWorldXZ * hexScale);
        vec3 hexRGB = texture(hexTex, hexUV).rgb;
        float hexLuma = dot(hexRGB, vec3(0.299, 0.587, 0.114));
        hexLine = smoothstep(0.55, 0.90, hexLuma);
    }

    float diffusionAlpha = mix(minBandAlpha, diffusionColor.a, boundaryBlend);
    float hexAlpha = hexLine * hexPatternAlpha * boundaryBlend;

    // Diffusion and hex opacity are independent. HEX_PATTERN_ALPHA = 1.0 can
    // therefore make the hex-line pixels fully opaque at the range boundary
    // even when MAX_BAND_ALPHA is much lower.
    vec3 color = diffusionColor.rgb * (0.62 + 0.38 * hexLine);
    float alpha = max(diffusionAlpha, hexAlpha);

    fragColor = vec4(color, alpha);
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
                hexTex = 1,
                useHexTex = 0,
                outwardBand = 0,
            },
            uniformFloat = {
                ringCenter = {0, 0, 0},
                ringRadius = 1,
                ringHalfWidth = 20,
                ringHeightOffset = RING_HEIGHT_OFFSET,
                diffusionColor = {1, 1, 1, MAX_BAND_ALPHA},
                minBandAlpha = MIN_BAND_ALPHA,
                hexScale = RING_HEX_WORLD_SCALE,
                hexPatternAlpha = HEX_PATTERN_ALPHA,
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
        diffusionUniforms.hexScale = gl.GetUniformLocation(diffusionShaderObj, "hexScale")
        diffusionUniforms.hexPatternAlpha = gl.GetUniformLocation(diffusionShaderObj, "hexPatternAlpha")
        diffusionUniforms.useHexTex = gl.GetUniformLocation(diffusionShaderObj, "useHexTex")
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
    gl.DepthTest(true)
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

local function EmitLegacyHexBandVertex(worldX, worldZ, color, alpha)
    local worldY = GetGroundHeight(worldX, worldZ) + RING_HEIGHT_OFFSET + 0.75
    glColor(color[1], color[2], color[3], alpha)
    glTexCoord(worldX / HEX_PATTERN_SIZE, worldZ / HEX_PATTERN_SIZE)
    glVertex(worldX, worldY, worldZ)
end

local function DrawLegacyHexBandGeometry(x, z, outerRadius, innerRadius, color, outerAlpha, innerAlpha)
    for i = 0, LEGACY_HEX_SEGMENTS do
        local angle = (i / LEGACY_HEX_SEGMENTS) * (2 * pi)
        local dx = cos(angle)
        local dz = sin(angle)

        EmitLegacyHexBandVertex(
            x + dx * outerRadius,
            z + dz * outerRadius,
            color,
            outerAlpha
        )
        EmitLegacyHexBandVertex(
            x + dx * innerRadius,
            z + dz * innerRadius,
            color,
            innerAlpha
        )
    end
end

local function DrawLegacyHexBand(x, y, z, radius, color, alphaScale, outwardBand)
    if
        not ringHexTexture
        or not glBeginEnd
        or not glVertex
        or not glTexCoord
        or not GetGroundHeight
    then
        return
    end

    local outerRadius
    local innerRadius
    local outerAlpha
    local innerAlpha

    if outwardBand then
        outerRadius = radius + BAND_THICKNESS
        innerRadius = radius
        outerAlpha = 0.0
        innerAlpha = HEX_PATTERN_ALPHA * alphaScale
    else
        outerRadius = radius
        innerRadius = max(0, radius - BAND_THICKNESS)
        if innerRadius >= radius then
            return
        end
        outerAlpha = HEX_PATTERN_ALPHA * alphaScale
        innerAlpha = 0.0
    end

    gl.PushAttrib(GL.ALL_ATTRIB_BITS)
    gl.Culling(false)
    gl.DepthTest(true)
    gl.DepthMask(false)

    -- Hex opacity is intentionally independent of the diffusion-band alpha.
    -- HEX_PATTERN_ALPHA = 1.0 therefore supplies full source alpha at the ring
    -- edge before the shared camera-distance visibility multiplier is applied.
    -- Additive blending lets the white grid contribute while the dark cell
    -- interiors add very little to the diffusion beneath it.
    gl.Blending(GL.SRC_ALPHA, GL.ONE)
    gl.Texture(ringHexTexture)
    glBeginEnd(
        GL.QUAD_STRIP,
        DrawLegacyHexBandGeometry,
        x, z, outerRadius, innerRadius, color, outerAlpha, innerAlpha
    )
    gl.Texture(false)

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
    gl.DepthTest(true)
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
        else
            DrawLegacyHexBand(x, y, z, radius, color, alphaScale, outwardBand)
        end
        return
    end

    local diffuseWidth = GetDiffusionWidth()
    local diffuseRadius = radius + ((outwardBand and 1 or -1) * diffuseWidth * 0.5)
    if diffuseRadius <= 0 then
        return
    end

    gl.Texture(0, "$heightmap")
    if ringHexTexture then
        gl.Texture(1, ringHexTexture)
    end

    diffusionShader:Activate()
    gl.Uniform(diffusionUniforms.ringCenter, x, y, z)
    gl.Uniform(diffusionUniforms.ringRadius, diffuseRadius)
    gl.Uniform(diffusionUniforms.ringHalfWidth, diffuseWidth * 0.5)
    gl.Uniform(diffusionUniforms.ringHeightOffset, RING_HEIGHT_OFFSET)
    gl.Uniform(diffusionUniforms.diffusionColor, color[1], color[2], color[3], MAX_BAND_ALPHA * alphaScale)
    gl.Uniform(diffusionUniforms.minBandAlpha, MIN_BAND_ALPHA * alphaScale)
    gl.Uniform(diffusionUniforms.hexScale, RING_HEX_WORLD_SCALE)
    gl.Uniform(diffusionUniforms.hexPatternAlpha, outwardBand and 0 or (HEX_PATTERN_ALPHA * alphaScale))
    gl.UniformInt(diffusionUniforms.useHexTex, (not outwardBand and ringHexTexture) and 1 or 0)
    gl.UniformInt(diffusionUniforms.outwardBand, outwardBand and 1 or 0)
    ringVAO:DrawArrays(GL.TRIANGLE_STRIP)
    diffusionShader:Deactivate()

    if ringHexTexture then
        gl.Texture(1, false)
    end
    gl.Texture(0, false)

    if outwardBand then
        DrawLegacyHazardBand(x, y, z, radius, color, alphaScale)
    end
end

local function DrawGL4RangeRing(x, y, z, radius, color, dashed, halfWidth, alphaScale)
    gl.PushAttrib(GL.ALL_ATTRIB_BITS)
    gl.Culling(false)
    gl.DepthTest(true)
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

local function DrawRangeRing(x, y, z, radius, color, dashed, halfWidth)
    local alphaScale = GetRangeVisualAlphaScale(x, y, z)

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
    else
        DrawLegacyHexBand(x, y, z, radius, color, alphaScale, dashed)
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

local AttackRed = {1.0, 0.2, 0.2, 0.7}
--local BuildGreen = {0.3, 1.0, 0.3, 0.5} -- doesn't match engine for some reason so make less opaque
local SalvageBlue = {0.77647, 0.88627, 1, 0.5}

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

function widget:Initialize()
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

local function ShouldDrawWeaponRanges(unitID)
	if
		select(
			2,
			GetActiveCommand()
		) == CMD.ATTACK
	then
		return true
	end

	return
		IsDirectControlledUnit(
			unitID
		)
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

function widget:DrawWorldPreUnit()
	for _,unitID in ipairs(GetSelectedUnits()) do
		local unitDefID = GetUnitDefID(unitID)
		if ShouldDrawWeaponRanges(unitID) then
			glColor(AttackRed)
			local maxRangesU, minRangesU = BuildActiveWeaponRanges(unitID, unitDefID)
			local x, y, z = GetUnitPosition(unitID)
			local labelSize = GetRangeLabelSize(x, y + 40, z)
			local ringHalfWidth = GetRangeRingHalfWidth(x, y, z)
			if maxRangesU then
				for radius, info in pairs(maxRangesU) do
					DrawRangeRing(x, y, z, radius, AttackRed, false, ringHalfWidth)
					gl.PushMatrix()
						glTranslate(x, y + 40, z + radius + 40)
						glBillboard()
						btFont:Print(info, 0, 0, labelSize, "oc")
					gl.PopMatrix()
				end
			end
			if minRangesU then
				for radius, info in pairs(minRangesU) do
					DrawRangeRing(x, y, z, radius, AttackRed, true, ringHalfWidth)
					gl.PushMatrix()
						glTranslate(x, y + 40, z + radius - 40)
						glBillboard()
						btFont:Print(info, 0, 0, labelSize, "oc")
					gl.PopMatrix()
				end
			end
		else
			rangesToDraw = salvageRanges[unitDefID]
			if rangesToDraw then
				local x, y, z = GetUnitPosition(unitID)
				glColor(SalvageBlue)
				local ringHalfWidth = GetRangeRingHalfWidth(x, y, z)
				DrawRangeRing(x, y, z, rangesToDraw, SalvageBlue, false, ringHalfWidth)
			end
		end
		glColor(1,1,1,1)
	end
end