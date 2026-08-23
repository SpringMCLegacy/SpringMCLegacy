--------------------------------------------------------------------------------
-- Map Edge Extension
--
-- UNIFIED TWO-RING CUSTOM-PROJECTION TERRAIN
--
-- Revision: 2026-08-23-two-ring-unified-custom-hex-r1
--
-- Design:
--
--   PASS 1: Near exterior terrain
--     - First mirrored ring only
--     - 32-elmo grid
--     - Native Recoil projection
--     - Native depth behavior
--     - Preserves the visually stable playable-map edge
--
--   PASS 2: Distant exterior terrain
--     - First ring beyond a safe handoff distance + full second ring
--     - 128-elmo second ring
--     - Fixed far projection used ONLY for distant exterior land
--     - Radial haze centered on the camera focus point
--
-- Native Recoil water and map-border behavior remain enabled and untouched.
--
-- Intentionally excluded:
--   - Custom water
--   - Ground pre/post call-ins
--   - SSMF reconstruction
--   - Normal-map lighting
--   - Automatic map-light calibration
--------------------------------------------------------------------------------

function widget:GetInfo()
    return {
        name      = "Map Edge Extension",
        desc      = "Stable two-ring mirrored terrain extension",
        author    = "YourGame",
        date      = "2026",
        license   = "GPLv2 or later",
        layer     = -1000,
        enabled   = true,
    }
end

local SOURCE_VERSION = "2026-08-23-two-ring-unified-custom-hex-r1"

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local CFG = {

    --------------------------------------------------------------------------
    -- Geometry
    --------------------------------------------------------------------------

    innerGridSize = 32,
    outerGridSize = 128,

    --------------------------------------------------------------------------
    -- Brightness
    --------------------------------------------------------------------------

    exteriorBrightness = 0.40,

    -- Main artistic control.
    --
    -- 1.00 = baseline
    -- 0.90 = 10% darker
    -- 1.10 = 10% brighter
    exteriorBrightnessAdjust = 1.00,

    --------------------------------------------------------------------------
    -- Hex overlay
    --------------------------------------------------------------------------

    -- World-space size of one repeated texture tile in elmos.
    -- Larger values create larger visible hex cells.
    hexTileWorldSize = 512,

    -- Overall overlay strength.
    -- 0.00 = invisible
    -- 1.00 = full texture strength
    hexOverlayOpacity = 0.18,

    -- Neutral tint by default.
    hexOverlayTint = {
        1.0,
        1.0,
        1.0,
    },

    --------------------------------------------------------------------------
    -- Exterior land / water boundary
    --------------------------------------------------------------------------

    -- Exterior terrain at or below the active water plane is discarded so
    -- native Recoil water remains responsible for submerged areas.
    waterHeightBias = 0.50,

    --------------------------------------------------------------------------
    -- Unified camera-focus haze
    --------------------------------------------------------------------------

    -- Both rings use this exact same radial haze function.
    -- Expressed as fractions of the smaller map dimension.
    focusFogStart = 0.65,
    focusFogEnd   = 1.65,

    --------------------------------------------------------------------------
    -- Custom projection
    --------------------------------------------------------------------------

    -- Used ONLY by the distant terrain pass.
    customFarClip = 100000,

    --------------------------------------------------------------------------
    -- Culling
    --------------------------------------------------------------------------

    cullMargin = 96,
}

--------------------------------------------------------------------------------
-- Map state
--------------------------------------------------------------------------------

local MAP = {
    sizeX = Game.mapSizeX,
    sizeZ = Game.mapSizeZ,

    minSize =
        math.min(
            Game.mapSizeX,
            Game.mapSizeZ
        ),

    maxSize =
        math.max(
            Game.mapSizeX,
            Game.mapSizeZ
        ),
}

--------------------------------------------------------------------------------
-- Renderer state
--------------------------------------------------------------------------------

local STATE = {
    shader = nil,
    uniform = {},

    minHeight = -1000,
    maxHeight = 1000,

    projectionLogged = false,

    layers = {
        inner = {
            gridSize = 32,
            sectors = {},
            maxInstances = 8,
            instanceCount = 0,
            instanceVBO = nil,
            vao = nil,
            cellsX = 0,
            cellsZ = 0,
            stepX = 0,
            stepZ = 0,
            vertexCount = 0,
        },

        outer = {
            gridSize = 128,
            sectors = {},
            maxInstances = 16,
            instanceCount = 0,
            instanceVBO = nil,
            vao = nil,
            cellsX = 0,
            cellsZ = 0,
            stepX = 0,
            stepZ = 0,
            vertexCount = 0,
        },
    },
}

--------------------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------------------

local ENV = {
    waterLevel = 0.0,

    fog = {
        r = 0.65,
        g = 0.68,
        b = 0.72,
    },

    fogStart = 10000,
    fogEnd   = 20000,
}

--------------------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------------------

local function SafeCall(func, ...)
    if not func then
        return nil
    end

    local result = {
        pcall(
            func,
            ...
        )
    }

    if not result[1] then
        return nil
    end

    table.remove(
        result,
        1
    )

    return unpack(
        result
    )
end

--------------------------------------------------------------------------------
-- Ground range
--------------------------------------------------------------------------------

local function DetectGroundRange()
    if not Spring.GetGroundExtremes then
        return
    end

    local minY, maxY =
        Spring.GetGroundExtremes()

    if minY then
        STATE.minHeight = minY
    end

    if maxY then
        STATE.maxHeight = maxY
    end
end

--------------------------------------------------------------------------------
-- Environment update
--------------------------------------------------------------------------------

local function UpdateEnvironment()
    if Spring.GetWaterPlaneLevel then
        local level =
            SafeCall(
                Spring.GetWaterPlaneLevel
            )

        if type(level) == "number" then
            ENV.waterLevel = level
        end
    end

    local farRange =
        MAP.maxSize * 2.0

    if gl.GetViewRange then
        local nearValue, farValue =
            gl.GetViewRange()

        if
            farValue
            and farValue > 100
        then
            farRange = farValue
        end
    end

    if gl.GetAtmosphere then
        local r, g, b =
            SafeCall(
                gl.GetAtmosphere,
                "fogColor"
            )

        if r and g and b then
            ENV.fog.r = r
            ENV.fog.g = g
            ENV.fog.b = b
        end

        local fogStart =
            SafeCall(
                gl.GetAtmosphere,
                "fogStart"
            )

        local fogEnd =
            SafeCall(
                gl.GetAtmosphere,
                "fogEnd"
            )

        if
            type(fogStart) == "number"
            and type(fogEnd) == "number"
        then
            ENV.fogStart =
                fogStart * farRange

            ENV.fogEnd =
                fogEnd * farRange
        else
            ENV.fogStart =
                farRange * 0.65

            ENV.fogEnd =
                farRange * 0.95
        end
    else
        ENV.fogStart =
            farRange * 0.65

        ENV.fogEnd =
            farRange * 0.95
    end

    if ENV.fogEnd <= ENV.fogStart then
        ENV.fogEnd =
            ENV.fogStart + 1
    end
end

--------------------------------------------------------------------------------
-- Camera focus
--------------------------------------------------------------------------------

local function GetCameraFocus()
    if Spring.GetCameraState then
        local state =
            Spring.GetCameraState()

        if
            type(state) == "table"
            and type(state.px) == "number"
            and type(state.pz) == "number"
        then
            return state.px, state.pz
        end
    end

    local x, y, z =
        Spring.GetCameraPosition()

    return x or 0, z or 0
end

--------------------------------------------------------------------------------
-- Mirrored sector generation
--------------------------------------------------------------------------------

local function MirrorParity(tile)
    if math.abs(tile) % 2 == 1 then
        return 1
    end

    return 0
end


local function MakeSector(tileX, tileZ)
    return {
        MirrorParity(tileX),
        MirrorParity(tileZ),
        tileX,
        tileZ,
        tileX,
        tileZ,
    }
end


local function BuildSectorLists()
    local inner =
        STATE.layers.inner.sectors

    local outer =
        STATE.layers.outer.sectors

    for tileZ = -1, 1 do
        for tileX = -1, 1 do
            if tileX ~= 0 or tileZ ~= 0 then
                inner[#inner + 1] =
                    MakeSector(
                        tileX,
                        tileZ
                    )
            end
        end
    end

    for tileZ = -2, 2 do
        for tileX = -2, 2 do
            local ring =
                math.max(
                    math.abs(tileX),
                    math.abs(tileZ)
                )

            if ring == 2 then
                outer[#outer + 1] =
                    MakeSector(
                        tileX,
                        tileZ
                    )
            end
        end
    end

    STATE.layers.inner.maxInstances =
        #inner

    STATE.layers.outer.maxInstances =
        #outer

    Spring.Echo(
        "[Map Edge Extension] Sectors: inner="
        .. #inner
        .. " outer="
        .. #outer
    )
end

--------------------------------------------------------------------------------
-- Layer geometry
--------------------------------------------------------------------------------

local function CalculateLayerGeometry(layerName)
    local layer =
        STATE.layers[layerName]

    layer.cellsX =
        math.max(
            1,
            math.ceil(
                MAP.sizeX
                / layer.gridSize
            )
        )

    layer.cellsZ =
        math.max(
            1,
            math.ceil(
                MAP.sizeZ
                / layer.gridSize
            )
        )

    layer.stepX =
        MAP.sizeX
        / layer.cellsX

    layer.stepZ =
        MAP.sizeZ
        / layer.cellsZ

    layer.vertexCount =
        layer.cellsX
        * layer.cellsZ
        * 6

    Spring.Echo(
        "[Map Edge Extension] "
        .. layerName
        .. " grid "
        .. layer.cellsX
        .. " x "
        .. layer.cellsZ
        .. ", "
        .. layer.vertexCount
        .. " vertices per instance"
    )
end

--------------------------------------------------------------------------------
-- Vertex shader
--------------------------------------------------------------------------------

local VERTEX_SHADER = [[
#version 330

layout(location = 0) in vec4 mirrorParams;

uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform sampler2D heightTex;

uniform vec2 mapSize;
uniform vec2 gridStep;
uniform float cellsX;

out DataVS
{
    vec2 uv;
    vec3 worldPos;
    float outsideDistance;
};


float OutsideDistance(vec2 p)
{
    float dx =
        max(
            max(
                -p.x,
                p.x - mapSize.x
            ),
            0.0
        );

    float dz =
        max(
            max(
                -p.y,
                p.y - mapSize.y
            ),
            0.0
        );

    return
        length(
            vec2(
                dx,
                dz
            )
        );
}


void main()
{
    int vertexID =
        gl_VertexID;

    int cellID =
        vertexID / 6;

    int cornerID =
        vertexID
        - cellID * 6;

    int gridCellsX =
        int(
            cellsX
        );

    int cellX =
        cellID
        % gridCellsX;

    int cellZ =
        cellID
        / gridCellsX;

    vec2 corner =
        vec2(0.0);

    if (cornerID == 0)
    {
        corner = vec2(0.0, 0.0);
    }
    else if (cornerID == 1)
    {
        corner = vec2(0.0, 1.0);
    }
    else if (cornerID == 2)
    {
        corner = vec2(1.0, 0.0);
    }
    else if (cornerID == 3)
    {
        corner = vec2(1.0, 0.0);
    }
    else if (cornerID == 4)
    {
        corner = vec2(0.0, 1.0);
    }
    else
    {
        corner = vec2(1.0, 1.0);
    }

    vec2 sourceXZ =
        vec2(
            float(cellX) * gridStep.x,
            float(cellZ) * gridStep.y
        )
        +
        corner * gridStep;

    sourceXZ =
        min(
            sourceXZ,
            mapSize
        );

    vec2 heightUV =
        sourceXZ
        / mapSize;

    float height =
        textureLod(
            heightTex,
            heightUV,
            0.0
        ).x;

    vec2 mirroredXZ =
        mix(
            sourceXZ,
            mapSize - sourceXZ,
            mirrorParams.xy
        );

    mirroredXZ +=
        mirrorParams.zw
        * mapSize;

    float outside =
        OutsideDistance(
            mirroredXZ
        );

    vec4 world =
        vec4(
            mirroredXZ.x,
            height,
            mirroredXZ.y,
            1.0
        );

    uv =
        sourceXZ
        / mapSize;

    worldPos =
        world.xyz;

    outsideDistance =
        outside;

    gl_Position =
        projectionMatrix
        * viewMatrix
        * world;
}
]]

--------------------------------------------------------------------------------
-- Fragment shader
--------------------------------------------------------------------------------

local FRAGMENT_SHADER = [[
#version 330

uniform sampler2D colorTex;
uniform sampler2D hexTex;

uniform vec2 mapSize;

uniform float exteriorBrightness;
uniform float exteriorBrightnessAdjust;

uniform float hexTileWorldSize;
uniform float hexOverlayOpacity;
uniform vec3 hexOverlayTint;

uniform vec2 focusPosition;

uniform vec3 fogColor;

uniform float focusFogStart;
uniform float focusFogEnd;

uniform float waterLevel;
uniform float waterHeightBias;

in DataVS
{
    vec2 uv;
    vec3 worldPos;
    float outsideDistance;
};

out vec4 fragColor;


const mat3 RGB2YCBCR =
    mat3(
         0.2126,
        -0.114572,
         0.5,

         0.7152,
        -0.385428,
        -0.454153,

         0.0722,
         0.5,
        -0.0458471
    );


const mat3 YCBCR2RGB =
    mat3(
        1.0,
        1.0,
        1.0,

        0.0,
       -0.187324,
        1.8556,

        1.5748,
       -0.468124,
        0.0
    );


vec3 ApplyExteriorBrightness(vec3 color)
{
    vec3 ycbcr =
        RGB2YCBCR
        * color;

    float brightnessFactor =
        exteriorBrightness
        * exteriorBrightnessAdjust;

    ycbcr.x =
        clamp(
            ycbcr.x
            * brightnessFactor,
            0.0,
            1.0
        );

    return
        YCBCR2RGB
        * ycbcr;
}


void main()
{
    // The extension is exterior-only. Even if a mirrored/custom-projection
    // triangle ever overlaps the playable rectangle in screen/depth space,
    // it is never allowed to shade pixels whose world X/Z lie inside it.
    bool insidePlayable =
        worldPos.x >= 0.0
        && worldPos.x <= mapSize.x
        && worldPos.z >= 0.0
        && worldPos.z <= mapSize.y;

    if (insidePlayable)
    {
        discard;
    }

    // Native Recoil water remains responsible for submerged exterior areas.
    if (worldPos.y <= waterLevel + waterHeightBias)
    {
        discard;
    }

    vec2 textureDimensions =
        vec2(
            textureSize(
                colorTex,
                0
            )
        );

    vec2 halfTexel =
        0.5
        / max(
            textureDimensions,
            vec2(1.0)
        );

    vec2 sampleUV =
        clamp(
            uv,
            halfTexel,
            vec2(1.0) - halfTexel
        );

    vec3 color =
        texture(
            colorTex,
            sampleUV
        ).rgb;

    color =
        ApplyExteriorBrightness(
            color
        );

    // World-space tiled overlay. Because UVs come from world X/Z rather than
    // mirrored source UVs, the pattern remains continuous across both rings.
    vec2 hexUV =
        worldPos.xz
        / max(
            hexTileWorldSize,
            1.0
        );

    vec4 hexSample =
        texture(
            hexTex,
            hexUV
        );

    float hexBlend =
        clamp(
            hexSample.a
            * hexOverlayOpacity,
            0.0,
            1.0
        );

    vec3 hexColor =
        hexSample.rgb
        * hexOverlayTint;

    color =
        mix(
            color,
            hexColor,
            hexBlend
        );

    float focusDistance =
        distance(
            focusPosition,
            worldPos.xz
        );

    float visibility =
        1.0
        - smoothstep(
            focusFogStart,
            focusFogEnd,
            focusDistance
        );

    color =
        mix(
            fogColor,
            color,
            visibility
        );

    fragColor =
        vec4(
            color,
            1.0
        );
}
]]

--------------------------------------------------------------------------------
-- Shader setup
--------------------------------------------------------------------------------

local REQUIRED_UNIFORMS = {
    "viewMatrix",
    "projectionMatrix",

    "mapSize",
    "gridStep",
    "cellsX",

    "exteriorBrightness",
    "exteriorBrightnessAdjust",

    "hexTileWorldSize",
    "hexOverlayOpacity",
    "hexOverlayTint",

    "focusPosition",

    "fogColor",

    "focusFogStart",
    "focusFogEnd",

    "waterLevel",
    "waterHeightBias",
}


local function InitShader()
    STATE.shader =
        gl.CreateShader({
            vertex = VERTEX_SHADER,
            fragment = FRAGMENT_SHADER,

            uniformInt = {
                heightTex = 0,
                colorTex  = 1,
                hexTex    = 2,
            },
        })

    if not STATE.shader then
        Spring.Echo(
            "[Map Edge Extension] ERROR: shader compilation failed"
        )

        if gl.GetShaderLog then
            local log =
                gl.GetShaderLog()

            if log then
                Spring.Echo(log)
            end
        end

        return false
    end

    for i = 1, #REQUIRED_UNIFORMS do
        local name =
            REQUIRED_UNIFORMS[i]

        local location =
            gl.GetUniformLocation(
                STATE.shader,
                name
            )

        if
            type(location) ~= "number"
            or location < 0
        then
            Spring.Echo(
                "[Map Edge Extension] ERROR: missing uniform "
                .. name
                .. " | revision "
                .. SOURCE_VERSION
            )

            return false
        end

        STATE.uniform[name] =
            location
    end

    Spring.Echo(
        "[Map Edge Extension] Shader and uniforms validated | revision "
        .. SOURCE_VERSION
    )

    return true
end

--------------------------------------------------------------------------------
-- Layer VBO / VAO
--------------------------------------------------------------------------------

local function BuildLayerVAO(layerName)
    local layer =
        STATE.layers[layerName]

    layer.instanceVBO =
        gl.GetVBO(
            GL.ARRAY_BUFFER,
            true
        )

    if not layer.instanceVBO then
        Spring.Echo(
            "[Map Edge Extension] ERROR: "
            .. layerName
            .. " instance VBO creation failed"
        )

        return false
    end

    layer.instanceVBO:Define(
        layer.maxInstances,
        {
            {
                id   = 0,
                name = "mirrorParams",
                size = 4,
            },
        }
    )

    local emptyData = {}

    for i = 1, layer.maxInstances do
        local base =
            (i - 1) * 4

        emptyData[base + 1] = 0
        emptyData[base + 2] = 0
        emptyData[base + 3] = 0
        emptyData[base + 4] = 0
    end

    layer.instanceVBO:Upload(
        emptyData
    )

    layer.vao =
        gl.GetVAO()

    if not layer.vao then
        Spring.Echo(
            "[Map Edge Extension] ERROR: "
            .. layerName
            .. " VAO creation failed"
        )

        return false
    end

    layer.vao:AttachInstanceBuffer(
        layer.instanceVBO
    )

    return true
end

--------------------------------------------------------------------------------
-- Forced exterior submission
--------------------------------------------------------------------------------

local function UpdateLayerInstances(layerName)
    local layer =
        STATE.layers[layerName]

    local data = {}
    local count =
        #layer.sectors

    -- Submit every exterior sector every frame.
    --
    -- The complete extension is only 24 instances:
    --   8 inner-ring tiles
    --   16 outer-ring tiles
    --
    -- No engine-side AABB visibility test is used. The GPU clip volume still
    -- discards triangles outside the actual camera view.
    for i = 1, #layer.sectors do
        local sector =
            layer.sectors[i]

        local base =
            (i - 1) * 4

        data[base + 1] = sector[1]
        data[base + 2] = sector[2]
        data[base + 3] = sector[3]
        data[base + 4] = sector[4]
    end

    layer.instanceVBO:Upload(
        data
    )

    layer.instanceCount =
        count
end

--------------------------------------------------------------------------------
-- Texture binding
--------------------------------------------------------------------------------

local function BindTextures()
    gl.Texture(
        0,
        "$heightmap"
    )

    gl.Texture(
        1,
        "$minimap"
    )

    gl.Texture(
        2,
        "bitmaps/maphex.png"
    )
end


local function UnbindTextures()
    gl.Texture(0, false)
    gl.Texture(1, false)
    gl.Texture(2, false)
end

--------------------------------------------------------------------------------
-- Extended projection for distant terrain only
--------------------------------------------------------------------------------

local function BuildExtendedProjection(engineProjection)
    if
        type(engineProjection) ~= "table"
        or #engineProjection ~= 16
    then
        return nil
    end

    local A =
        engineProjection[11]

    local B =
        engineProjection[15]

    if
        type(A) ~= "number"
        or type(B) ~= "number"
    then
        return nil
    end

    local nearDenominator =
        A - 1.0

    local farDenominator =
        A + 1.0

    if math.abs(nearDenominator) < 0.000001 then
        return nil
    end

    local nearClip =
        B / nearDenominator

    local engineFarClip =
        nil

    if math.abs(farDenominator) >= 0.000001 then
        engineFarClip =
            B / farDenominator
    end

    if
        type(nearClip) ~= "number"
        or nearClip <= 0
    then
        return nil
    end

    local farClip =
        math.max(
            CFG.customFarClip,
            nearClip + 1000
        )

    local customA =
        -(farClip + nearClip)
        / (farClip - nearClip)

    local customB =
        -(2.0 * farClip * nearClip)
        / (farClip - nearClip)

    local result = {}

    for i = 1, 16 do
        result[i] =
            engineProjection[i]
    end

    result[11] =
        customA

    result[15] =
        customB

    if not STATE.projectionLogged then
        STATE.projectionLogged =
            true

        Spring.Echo(
            string.format(
                "[Map Edge Extension] Distant projection: near=%.3f engineFar=%s customFar=%.1f",
                nearClip,
                engineFarClip and string.format("%.1f", engineFarClip) or "unknown",
                farClip
            )
        )
    end

    return result
end

--------------------------------------------------------------------------------
-- Shared draw uniforms
--------------------------------------------------------------------------------

local function UploadSharedUniforms(focusX, focusZ)
    local U =
        STATE.uniform

    gl.Uniform(
        U.mapSize,
        MAP.sizeX,
        MAP.sizeZ
    )

    gl.Uniform(
        U.exteriorBrightness,
        CFG.exteriorBrightness
    )

    gl.Uniform(
        U.exteriorBrightnessAdjust,
        CFG.exteriorBrightnessAdjust
    )

    gl.Uniform(
        U.hexTileWorldSize,
        CFG.hexTileWorldSize
    )

    gl.Uniform(
        U.hexOverlayOpacity,
        CFG.hexOverlayOpacity
    )

    gl.Uniform(
        U.hexOverlayTint,
        CFG.hexOverlayTint[1],
        CFG.hexOverlayTint[2],
        CFG.hexOverlayTint[3]
    )

    gl.Uniform(
        U.focusPosition,
        focusX,
        focusZ
    )

    gl.Uniform(
        U.fogColor,
        ENV.fog.r,
        ENV.fog.g,
        ENV.fog.b
    )

    gl.Uniform(
        U.focusFogStart,
        CFG.focusFogStart * MAP.minSize
    )

    gl.Uniform(
        U.focusFogEnd,
        CFG.focusFogEnd * MAP.minSize
    )

    gl.Uniform(
        U.waterLevel,
        ENV.waterLevel
    )

    gl.Uniform(
        U.waterHeightBias,
        CFG.waterHeightBias
    )
end

--------------------------------------------------------------------------------
-- Draw one layer
--------------------------------------------------------------------------------

local function DrawLayer(layerName)
    local layer =
        STATE.layers[layerName]

    if
        not layer.vao
        or layer.instanceCount <= 0
    then
        return
    end

    local U =
        STATE.uniform

    gl.Uniform(
        U.gridStep,
        layer.stepX,
        layer.stepZ
    )

    gl.Uniform(
        U.cellsX,
        layer.cellsX
    )

    layer.vao:DrawArrays(
        GL.TRIANGLES,
        layer.vertexCount,
        0,
        layer.instanceCount,
        0
    )
end

--------------------------------------------------------------------------------
-- Complete draw
--------------------------------------------------------------------------------

local function DrawExtension()
    local view = {
        gl.GetMatrixData(
            "view"
        )
    }

    local engineProjection = {
        gl.GetMatrixData(
            "projection"
        )
    }

    if
        #view ~= 16
        or #engineProjection ~= 16
    then
        return
    end

    local extendedProjection =
        BuildExtendedProjection(
            engineProjection
        )

    if not extendedProjection then
        return
    end

    local focusX, focusZ =
        GetCameraFocus()

    local U =
        STATE.uniform

    BindTextures()

    gl.UseShader(
        STATE.shader
    )

    gl.UniformMatrix(
        U.viewMatrix,
        unpack(view)
    )

    gl.UniformMatrix(
        U.projectionMatrix,
        unpack(extendedProjection)
    )

    UploadSharedUniforms(
        focusX,
        focusZ
    )

    -- One projection, one haze model, two resolutions.
    DrawLayer(
        "outer"
    )

    DrawLayer(
        "inner"
    )

    gl.UseShader(
        0
    )

    UnbindTextures()
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function widget:Initialize()
    Spring.Echo(
        "[Map Edge Extension] Initializing STABLE TWO-RING renderer | revision "
        .. SOURCE_VERSION
    )

    if
        not gl.CreateShader
        or not gl.GetVBO
        or not gl.GetVAO
        or not gl.GetMatrixData
    then
        Spring.Echo(
            "[Map Edge Extension] ERROR: required GL APIs unavailable"
        )

        widgetHandler:RemoveWidget(
            self
        )

        return
    end

    if not Spring.GetCameraPosition then
        Spring.Echo(
            "[Map Edge Extension] ERROR: camera API unavailable"
        )

        widgetHandler:RemoveWidget(
            self
        )

        return
    end

    STATE.layers.inner.gridSize =
        CFG.innerGridSize

    STATE.layers.outer.gridSize =
        CFG.outerGridSize

    BuildSectorLists()
    DetectGroundRange()

    CalculateLayerGeometry(
        "inner"
    )

    CalculateLayerGeometry(
        "outer"
    )

    if not InitShader() then
        widgetHandler:RemoveWidget(
            self
        )

        return
    end

    if not BuildLayerVAO(
        "inner"
    ) then
        widgetHandler:RemoveWidget(
            self
        )

        return
    end

    if not BuildLayerVAO(
        "outer"
    ) then
        widgetHandler:RemoveWidget(
            self
        )

        return
    end

    UpdateEnvironment()

    Spring.SendCommands(
        "mapborder on"
    )

    Spring.Echo(
        "[Map Edge Extension] Native map border/water: ENABLED"
    )

    Spring.Echo(
        "[Map Edge Extension] Both rings projection: custom far plane"
    )

    Spring.Echo(
        "[Map Edge Extension] Both rings haze: unified camera-focus radial"
    )

    Spring.Echo(
        "[Map Edge Extension] Exterior submerged terrain: discarded"
    )

    Spring.Echo(
        "[Map Edge Extension] Exterior terrain culling: DISABLED"
    )

    Spring.Echo(
        "[Map Edge Extension] Forced exterior instances: 24"
    )

    Spring.Echo(
        "[Map Edge Extension] Hex overlay: bitmaps/maphex.png"
    )

    Spring.Echo(
        string.format(
            "[Map Edge Extension] Hex tile size: %.1f | opacity: %.3f",
            CFG.hexTileWorldSize,
            CFG.hexOverlayOpacity
        )
    )

    Spring.Echo(
        "[Map Edge Extension] Ready | revision "
        .. SOURCE_VERSION
    )
end

--------------------------------------------------------------------------------
-- World rendering
--------------------------------------------------------------------------------

function widget:DrawWorldPreUnit()
    if not STATE.shader then
        return
    end

    UpdateLayerInstances(
        "inner"
    )

    UpdateLayerInstances(
        "outer"
    )

    if
        STATE.layers.inner.instanceCount <= 0
        and STATE.layers.outer.instanceCount <= 0
    then
        return
    end

    UpdateEnvironment()

    if gl.ResetState then
        gl.ResetState()
    end

    gl.Blending(
        false
    )

    gl.DepthTest(
        GL.LEQUAL
    )

    gl.DepthMask(
        true
    )

    gl.Culling(
        false
    )

    DrawExtension()

    gl.UseShader(
        0
    )

    UnbindTextures()

    if gl.ResetState then
        gl.ResetState()
    else
        gl.DepthTest(false)
        gl.DepthMask(false)
        gl.Culling(false)
    end
end

--------------------------------------------------------------------------------
-- Cleanup
--------------------------------------------------------------------------------

local function DestroyLayer(layerName)
    local layer =
        STATE.layers[layerName]

    if layer.vao then
        if layer.vao.Delete then
            layer.vao:Delete()
        end

        layer.vao = nil
    end

    if layer.instanceVBO then
        if layer.instanceVBO.Delete then
            layer.instanceVBO:Delete()
        end

        layer.instanceVBO = nil
    end
end


function widget:Shutdown()
    Spring.SendCommands(
        "mapborder on"
    )

    if STATE.shader then
        if gl.DeleteShader then
            gl.DeleteShader(
                STATE.shader
            )
        end

        STATE.shader = nil
    end

    DestroyLayer(
        "inner"
    )

    DestroyLayer(
        "outer"
    )
end
