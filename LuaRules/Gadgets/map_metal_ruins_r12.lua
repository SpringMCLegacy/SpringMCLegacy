--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Map Debris & Template Camps
--
--  Map dressing:
--      Uses detected metal-deposit count only as a density baseline.
--      Dressing positions themselves are randomized across playable land.
--      Every dressing site uses a randomized FeatureDef from:
--
--          features/ruins/
--
--  Camps:
--      Reads camp positions from the current map's flagConfig profile.
--      Buildings are drawn from:
--
--          features/buildings/
--
--      Camps use authored templates loaded from one shared config table.
--
--          * one ground-decal image
--          * decal dimensions
--          * a reference camp radius
--          * authored building sockets matching clearings in that image
--          * authored building facings
--
--      All template definitions live in:
--
--          LuaRules/Configs/camp_configs.lua
--
--      Adding a new template therefore requires only its PNG in
--      bitmaps/Decals/camps/ and a new table entry in camp_configs.lua;
--      the core gadget does not need to be edited.
--
--      The map profile may optionally select a specific template:
--
--          {
--              x = 4694,
--              z = 3526,
--              template = "template1",
--              rotation = 0, -- degrees, optional explicit override
--          },
--
--      If template is omitted, one available template is selected randomly.
--      Template size and maximum building count are authored by the template.
--      Most camps fill every socket; occasionally one or two sockets are left
--      empty for visual variation.
--
--  Revision 12:
--      - Removes random/default camp radius scaling; templates now always use
--        their authored width, height, socket positions and exclusion radius.
--      - Removes flagConfig radius and building-count overrides.
--      - Removes per-template buildingsMin/buildingsMax; socket count is now
--        the template's maximum building count.
--      - Most camps fill every socket, with a low chance of one empty socket
--        and a smaller chance of two empty sockets.
--      - flagConfig may still select a specific template and rotation.
--
--  Revision 11:
--      - Consolidates all camp template definitions into one shared config:
--        LuaRules/Configs/camp_configs.lua.
--      - Removes per-template Lua config discovery.
--      - Keeps template1/template2 behavior and per-template defaults.
--
--  Revision 10:
--      - Moves camp template metadata and building sockets out of the gadget.
--      - Adds per-template default building-count ranges.
--      - Adds template2 support.
--
--  Revision 9:
--      - Adds random default camp orientation.
--      - Keeps explicit per-camp rotation overrides when provided in flagConfig.
--
--  Revision 8:
--      - Reduces template1 to approximately half its r7 linear size.
--      - Scales all six authored building sockets by the same 0.5 factor so
--        building placement remains aligned with the decal clearings.
--      - Keeps the template image itself unchanged.
--
--  Revision 7:
--      - Adds template-driven camp placement.
--      - Adds template1 with six authored building sockets.
--      - Adds persistent camp ground decals through the Recoil Lua decal API.
--      - Keeps the road texture grayscale and applies a neutral tint for now.
--      - Adds optional per-camp manual decal tint override as groundwork for
--        future automatic map-colour sampling.
--      - Keeps random features/ruins/ map dressing from r6.
--      - Random debris now avoids camp footprints.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
    return {
        name      = "Map Debris & Template Camps",
        desc      = "Scatters debris and populates decal-driven camp templates",
        author    = "zvero + ChatGPT",
        date      = "2026",
        license   = "GPL v2 or later",
        layer     = 0,
        enabled   = true,
    }
end

--------------------------------------------------------------------------------
-- Shared template data
--------------------------------------------------------------------------------

local CAMP_DECAL_ACTION = "mcl_camp_template_decal"
local TWO_PI = math.pi * 2

local CAMP_CONFIG_PATH =
    "LuaRules/Configs/camp_configs.lua"

local CAMP_TEMPLATES = {}
local CAMP_TEMPLATE_ORDER = {}

local function LoadCampConfigs()
    CAMP_TEMPLATES = {}
    CAMP_TEMPLATE_ORDER = {}

    local success, configs =
        pcall(
            VFS.Include,
            CAMP_CONFIG_PATH,
            nil,
            VFS.GAME
        )

    if not success then
        Spring.Echo(
            "[Map Debris & Template Camps] ERROR: Failed to load camp config:",
            CAMP_CONFIG_PATH,
            configs
        )
        return false
    end

    if type(configs) ~= "table" then
        Spring.Echo(
            "[Map Debris & Template Camps] ERROR: Camp config did not return a table:",
            CAMP_CONFIG_PATH
        )
        return false
    end

    local names = {}

    for name, template in pairs(configs) do
        if
            type(name) == "string"
            and type(template) == "table"
        then
            names[#names + 1] = name
        end
    end

    table.sort(names)

    for i = 1, #names do
        local name = names[i]
        local template = configs[name]

        if
            type(template.texture) ~= "string"
            or type(template.width) ~= "number"
            or type(template.height) ~= "number"
            or type(template.sockets) ~= "table"
            or #template.sockets == 0
        then
            Spring.Echo(
                "[Map Debris & Template Camps] WARNING: Camp template is missing required fields:",
                name
            )
        else
            template.name = name

            if
                type(template.dressingExclusionRadius)
                ~= "number"
            then
                template.dressingExclusionRadius =
                    math.sqrt(
                        template.width
                        * template.width
                        + template.height
                        * template.height
                    )
                    * 0.5
            end

            if type(template.tint) ~= "table" then
                template.tint =
                    {0.5, 0.5, 0.5, 0.5}
            end

            template.alpha =
                tonumber(template.alpha)
                or 0.72

            CAMP_TEMPLATES[name] =
                template

            CAMP_TEMPLATE_ORDER[
                #CAMP_TEMPLATE_ORDER + 1
            ] = name
        end
    end

    Spring.Echo(
        "[Map Debris & Template Camps] Loaded",
        #CAMP_TEMPLATE_ORDER,
        "camp templates from",
        CAMP_CONFIG_PATH
    )

    return
        #CAMP_TEMPLATE_ORDER > 0
end

LoadCampConfigs()

--------------------------------------------------------------------------------
-- Unsynced camp-decal renderer
--------------------------------------------------------------------------------

if not gadgetHandler:IsSyncedCode() then
    local decalIDs = {}
    local decalTextureByFile = {}
    local warnedMissingTexture = {}

    local function NormalizePath(path)
        if type(path) ~= "string" then
            return nil
        end

        path = string.lower(path:gsub("\\", "/"))
        path = path:gsub("^bitmaps/", "")
        path = path:gsub("^/", "")

        return path
    end

    local function BuildCampTextureLookup()
        decalTextureByFile = {}

        if not Spring.GetGroundDecalTextures then
            Spring.Echo(
                "[Map Debris & Template Camps] WARNING: Spring.GetGroundDecalTextures unavailable; camp decals disabled."
            )
            return
        end

        local textureNames, textureFiles =
            Spring.GetGroundDecalTextures(true, true)

        if
            type(textureNames) ~= "table"
            or type(textureFiles) ~= "table"
        then
            Spring.Echo(
                "[Map Debris & Template Camps] WARNING: Could not read ground-decal atlas filenames; camp decals disabled."
            )
            return
        end

        for i = 1, #textureNames do
            local textureName = textureNames[i]
            local textureFile = textureFiles[i]
            local normalized = NormalizePath(textureFile)

            if normalized and type(textureName) == "string" then
                decalTextureByFile[normalized] = textureName
            end
        end
    end

    local function ResolveCampTexture(filePath)
        local normalized = NormalizePath(filePath)

        if not normalized then
            return nil
        end

        local exact = decalTextureByFile[normalized]

        if exact then
            return exact
        end

        -- Filename fallback handles atlas entries that differ only in their
        -- leading path. It deliberately refuses ambiguous duplicate basenames.
        local basename = normalized:match("([^/]+)$")

        if not basename then
            return nil
        end

        local matchedName = nil

        for registeredFile, registeredName in pairs(decalTextureByFile) do
            if registeredFile:match("([^/]+)$") == basename then
                if matchedName and matchedName ~= registeredName then
                    return nil
                end

                matchedName = registeredName
            end
        end

        return matchedName
    end

    local function CreateCampDecal(
        _,
        templateName,
        x,
        z,
        halfWidth,
        halfHeight,
        rotation,
        tintR,
        tintG,
        tintB,
        tintA,
        alpha
    )
        local template = CAMP_TEMPLATES[templateName]

        if
            not template
            or type(x) ~= "number"
            or type(z) ~= "number"
            or type(halfWidth) ~= "number"
            or type(halfHeight) ~= "number"
        then
            return
        end

        if
            not Spring.CreateGroundDecal
            or not Spring.SetGroundDecalPosAndDims
            or not Spring.SetGroundDecalTexture
        then
            return
        end

        local textureName =
            ResolveCampTexture(template.texture)

        if not textureName then
            local key = NormalizePath(template.texture) or template.texture

            if not warnedMissingTexture[key] then
                warnedMissingTexture[key] = true
                Spring.Echo(
                    "[Map Debris & Template Camps] WARNING: Camp texture is not present on the ground-decal atlas:",
                    template.texture
                )
            end

            return
        end

        local decalID = Spring.CreateGroundDecal()

        if not decalID then
            return
        end

        Spring.SetGroundDecalPosAndDims(
            decalID,
            x,
            z,
            halfWidth,
            halfHeight
        )

        if Spring.SetGroundDecalRotation then
            Spring.SetGroundDecalRotation(
                decalID,
                tonumber(rotation) or 0
            )
        end

        if not Spring.SetGroundDecalTexture(
            decalID,
            textureName,
            true
        ) then
            Spring.DestroyGroundDecal(decalID)
            return
        end

        if Spring.SetGroundDecalTint then
            Spring.SetGroundDecalTint(
                decalID,
                tonumber(tintR) or 0.5,
                tonumber(tintG) or 0.5,
                tonumber(tintB) or 0.5,
                tonumber(tintA) or 0.5
            )
        end

        if Spring.SetGroundDecalAlpha then
            Spring.SetGroundDecalAlpha(
                decalID,
                tonumber(alpha) or template.alpha or 0.72,
                0
            )
        end

        decalIDs[#decalIDs + 1] = decalID
    end

    function gadget:Initialize()
        BuildCampTextureLookup()

        gadgetHandler:AddSyncAction(
            CAMP_DECAL_ACTION,
            CreateCampDecal
        )
    end

    function gadget:Shutdown()
        gadgetHandler:RemoveSyncAction(
            CAMP_DECAL_ACTION
        )

        if Spring.DestroyGroundDecal then
            for i = 1, #decalIDs do
                Spring.DestroyGroundDecal(
                    decalIDs[i]
                )
            end
        end
    end

    return
end

--------------------------------------------------------------------------------
-- Synced tuning
--------------------------------------------------------------------------------

local CAMP_BUILDING_MIN_SPACING = 120

-- The detected metal-deposit count is used only as a map-density baseline.
local MAP_DRESSING_MIN_SPACING = 140
local MAP_DRESSING_PLACEMENT_ATTEMPTS = 60
local MAP_DRESSING_EDGE_MARGIN = 96
local MAP_DRESSING_CAMP_MARGIN = 80

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local placed = false
local ruinFeatureNames = {}
local buildingFeatureNames = {}

--------------------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------------------

local function Debug(...)
    Spring.Echo(
        "[Map Debris & Template Camps]",
        ...
    )
end

local function Clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    elseif value > maximum then
        return maximum
    end

    return value
end

local function DegreesToRadians(degrees)
    return (tonumber(degrees) or 0) * math.pi / 180
end

local function RadiansToHeading(radians)
    radians = radians % TWO_PI

    return math.floor(
        radians / TWO_PI * 65536 + 0.5
    ) % 65536
end

local function ShuffleCopy(source)
    local copy = {}

    for i = 1, #source do
        copy[i] = source[i]
    end

    for i = #copy, 2, -1 do
        local j = math.random(1, i)
        copy[i], copy[j] = copy[j], copy[i]
    end

    return copy
end

--------------------------------------------------------------------------------
-- Feature-pool discovery
--------------------------------------------------------------------------------

local function DiscoverFeatureFolder(folder, description)
    local featureNames = {}
    local files = VFS.DirList(
        folder,
        "*.lua",
        VFS.GAME
    ) or {}

    if #files == 0 then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: No .lua files found in",
            folder
        )
        return featureNames
    end

    local alreadyAdded = {}

    for i = 1, #files do
        local path = files[i]
        local success, returnedDefs = pcall(
            VFS.Include,
            path,
            nil,
            VFS.GAME
        )

        if not success then
            Spring.Echo(
                "[Map Debris & Template Camps] WARNING: Failed to inspect feature file:",
                path,
                returnedDefs
            )
        elseif type(returnedDefs) == "table" then
            for featureName, featureDef in pairs(returnedDefs) do
                if
                    type(featureName) == "string"
                    and type(featureDef) == "table"
                then
                    local normalizedName =
                        string.lower(featureName)

                    if
                        FeatureDefNames[normalizedName]
                        and not alreadyAdded[normalizedName]
                    then
                        alreadyAdded[normalizedName] = true

                        featureNames[
                            #featureNames + 1
                        ] = normalizedName
                    end
                end
            end
        end
    end

    table.sort(featureNames)

    Debug(
        "Discovered",
        #featureNames,
        description,
        "FeatureDefs in",
        folder
    )

    return featureNames
end

local function FindRuinFeatures()
    ruinFeatureNames = DiscoverFeatureFolder(
        "features/ruins/",
        "map-dressing ruin"
    )

    return #ruinFeatureNames > 0
end

local function FindBuildingFeatures()
    buildingFeatureNames = DiscoverFeatureFolder(
        "features/buildings/",
        "camp building"
    )

    return #buildingFeatureNames > 0
end

--------------------------------------------------------------------------------
-- Metal-deposit count
--
-- Coordinates are intentionally discarded. The deposits only establish the
-- amount of random map dressing, as in r6.
--------------------------------------------------------------------------------

local function DetectMetalDeposits()
    local metalMapX, metalMapZ =
        Spring.GetMetalMapSize()

    if not metalMapX or not metalMapZ then
        Spring.Echo(
            "[Map Debris & Template Camps] ERROR: Spring.GetMetalMapSize() failed."
        )
        return {}
    end

    local cellSize =
        Game.metalMapSquareSize or 16

    local metal = {}
    local visited = {}

    local function Index(x, z)
        return z * metalMapX + x + 1
    end

    local metalCellCount = 0

    for z = 0, metalMapZ - 1 do
        for x = 0, metalMapX - 1 do
            local amount =
                Spring.GetMetalAmount(x, z)
                or 0

            if amount > 0 then
                metal[Index(x, z)] = amount
                metalCellCount = metalCellCount + 1
            end
        end
    end

    Debug(
        "Scanning metal map:",
        metalMapX,
        "x",
        metalMapZ,
        "cells; metal-bearing cells:",
        metalCellCount
    )

    if metalCellCount == 0 then
        return {}
    end

    local neighbours = {
        {-1, -1},
        { 0, -1},
        { 1, -1},

        {-1,  0},
        { 1,  0},

        {-1,  1},
        { 0,  1},
        { 1,  1},
    }

    local deposits = {}

    for startZ = 0, metalMapZ - 1 do
        for startX = 0, metalMapX - 1 do
            local startIndex =
                Index(startX, startZ)

            if
                metal[startIndex]
                and not visited[startIndex]
            then
                local queueX = {startX}
                local queueZ = {startZ}
                local queueFirst = 1
                local queueLast = 1

                visited[startIndex] = true

                local weightedX = 0
                local weightedZ = 0
                local totalMetal = 0
                local cellCount = 0

                while queueFirst <= queueLast do
                    local x = queueX[queueFirst]
                    local z = queueZ[queueFirst]

                    queueFirst = queueFirst + 1

                    local index = Index(x, z)
                    local amount = metal[index]

                    if amount then
                        local worldX =
                            (x + 0.5) * cellSize

                        local worldZ =
                            (z + 0.5) * cellSize

                        weightedX =
                            weightedX + worldX * amount

                        weightedZ =
                            weightedZ + worldZ * amount

                        totalMetal =
                            totalMetal + amount

                        cellCount =
                            cellCount + 1

                        for n = 1, #neighbours do
                            local nx =
                                x + neighbours[n][1]

                            local nz =
                                z + neighbours[n][2]

                            if
                                nx >= 0
                                and nx < metalMapX
                                and nz >= 0
                                and nz < metalMapZ
                            then
                                local neighbourIndex =
                                    Index(nx, nz)

                                if
                                    metal[neighbourIndex]
                                    and not visited[neighbourIndex]
                                then
                                    visited[neighbourIndex] = true
                                    queueLast = queueLast + 1
                                    queueX[queueLast] = nx
                                    queueZ[queueLast] = nz
                                end
                            end
                        end
                    end
                end

                if totalMetal > 0 then
                    deposits[#deposits + 1] = {
                        x = weightedX / totalMetal,
                        z = weightedZ / totalMetal,
                        totalMetal = totalMetal,
                        cells = cellCount,
                    }
                end
            end
        end
    end

    Debug(
        "Detected",
        #deposits,
        "metal deposits."
    )

    return deposits
end

--------------------------------------------------------------------------------
-- Nav Beacon exclusion
--------------------------------------------------------------------------------

local function FindNavBeacons()
    local beacons = {}
    local beaconDef =
        UnitDefNames["beacon"]

    if not beaconDef then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: MCL Nav Beacon UnitDef 'beacon' was not found."
        )
        return beacons
    end

    local units =
        Spring.GetAllUnits()

    for i = 1, #units do
        local unitID = units[i]

        if
            Spring.GetUnitDefID(unitID)
            == beaconDef.id
        then
            local x, _, z =
                Spring.GetUnitPosition(unitID)

            if x and z then
                beacons[#beacons + 1] = {
                    x = x,
                    z = z,
                }
            end
        end
    end

    Debug(
        "Detected",
        #beacons,
        "Nav Beacons."
    )

    return beacons
end

local function IsNearNavBeacon(x, z, beacons)
    for i = 1, #beacons do
        local dx = x - beacons[i].x
        local dz = z - beacons[i].z

        if
            dx * dx + dz * dz
            < 90000
        then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Map camp profile and template resolution
--------------------------------------------------------------------------------

local function LoadCamps()
    local profilePath =
        "maps/flagConfig/"
        .. Game.mapName
        .. "_profile.lua"

    if not VFS.FileExists(profilePath) then
        Debug(
            "No flagConfig profile found for",
            Game.mapName,
            "- no camps will be placed."
        )
        return {}
    end

    local success, _, _, _, camps =
        pcall(
            VFS.Include,
            profilePath
        )

    if not success then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: Failed to load map profile for camps:",
            profilePath
        )
        return {}
    end

    if type(camps) ~= "table" then
        Debug(
            "Map profile contains no returned camps table:",
            profilePath
        )
        return {}
    end

    Debug(
        "Loaded",
        #camps,
        "camp positions from map profile."
    )

    return camps
end

local function ResolveCampTemplate(camp)
    if camp._resolvedTemplate then
        return
            camp._resolvedTemplate,
            CAMP_TEMPLATES[
                camp._resolvedTemplate
            ]
    end

    local requested =
        camp.template

    if
        requested
        and CAMP_TEMPLATES[requested]
    then
        camp._resolvedTemplate = requested
    else
        if requested then
            Spring.Echo(
                "[Map Debris & Template Camps] WARNING: Unknown camp template",
                tostring(requested),
                "- using a random available template."
            )
        end

        if #CAMP_TEMPLATE_ORDER == 0 then
            return nil, nil
        end

        camp._resolvedTemplate =
            CAMP_TEMPLATE_ORDER[
                math.random(
                    1,
                    #CAMP_TEMPLATE_ORDER
                )
            ]
    end

    return
        camp._resolvedTemplate,
        CAMP_TEMPLATES[
            camp._resolvedTemplate
        ]
end

local function ResolveCampRotation(camp)
    if camp._resolvedRotation then
        return camp._resolvedRotation
    end

    if type(camp.rotation) == "number" then
        camp._resolvedRotation =
            DegreesToRadians(
                camp.rotation
            )
    else
        camp._resolvedRotation =
            math.random() * TWO_PI
    end

    return camp._resolvedRotation
end

local function ResolveCampTint(camp, template)
    local tint = template.tint

    if type(camp.tint) == "table" then
        tint = camp.tint
    end

    return
        tonumber(tint[1]) or 0.5,
        tonumber(tint[2]) or 0.5,
        tonumber(tint[3]) or 0.5,
        tonumber(tint[4]) or 0.5
end

local function ResolveCampBuildingCount(template)
    local maximum = #template.sockets

    if maximum <= 1 then
        return maximum
    end

    -- Sparse variation:
    --   70% use every authored socket.
    --   22% leave one socket empty.
    --    8% leave two sockets empty.
    local roll = math.random()

    if roll < 0.70 then
        return maximum
    elseif roll < 0.92 then
        return maximum - 1
    end

    return math.max(1, maximum - 2)
end

--------------------------------------------------------------------------------
-- Random map dressing placement
--------------------------------------------------------------------------------

local function SpawnMapRuin(x, z)
    if #ruinFeatureNames == 0 then
        return nil
    end

    local featureName =
        ruinFeatureNames[
            math.random(
                1,
                #ruinFeatureNames
            )
        ]

    return Spring.CreateFeature(
        featureName,
        x,
        Spring.GetGroundHeight(x, z),
        z,
        math.random(0, 65535)
    )
end

local function IsMapDressingPositionClear(
    x,
    z,
    positions
)
    local minimumDistanceSquared =
        MAP_DRESSING_MIN_SPACING
        * MAP_DRESSING_MIN_SPACING

    for i = 1, #positions do
        local dx = x - positions[i].x
        local dz = z - positions[i].z

        if
            dx * dx + dz * dz
            < minimumDistanceSquared
        then
            return false
        end
    end

    return true
end

local function IsNearCampFootprint(x, z, camps)
    for i = 1, #camps do
        local camp = camps[i]

        if
            type(camp) == "table"
            and type(camp.x) == "number"
            and type(camp.z) == "number"
        then
            local _, template =
                ResolveCampTemplate(camp)

            if template then
                local radius =
                    template.dressingExclusionRadius
                    + MAP_DRESSING_CAMP_MARGIN

                local dx = x - camp.x
                local dz = z - camp.z

                if
                    dx * dx + dz * dz
                    < radius * radius
                then
                    return true
                end
            end
        end
    end

    return false
end

local function FindMapDressingPosition(
    beacons,
    camps,
    positions
)
    local marginX =
        math.min(
            MAP_DRESSING_EDGE_MARGIN,
            Game.mapSizeX * 0.25
        )

    local marginZ =
        math.min(
            MAP_DRESSING_EDGE_MARGIN,
            Game.mapSizeZ * 0.25
        )

    for attempt = 1,
        MAP_DRESSING_PLACEMENT_ATTEMPTS
    do
        local x =
            marginX
            + math.random()
            * (
                Game.mapSizeX
                - marginX * 2
            )

        local z =
            marginZ
            + math.random()
            * (
                Game.mapSizeZ
                - marginZ * 2
            )

        local groundHeight =
            Spring.GetGroundHeight(x, z)

        if
            groundHeight >= 0
            and not IsNearNavBeacon(
                x,
                z,
                beacons
            )
            and not IsNearCampFootprint(
                x,
                z,
                camps
            )
            and IsMapDressingPositionClear(
                x,
                z,
                positions
            )
        then
            return x, z
        end
    end

    return nil, nil
end

local function PlaceMapDressing(
    beacons,
    camps
)
    local deposits =
        DetectMetalDeposits()

    local targetCount =
        #deposits

    if targetCount == 0 then
        Debug(
            "No metal deposits found; map-dressing density baseline is zero."
        )
        return
    end

    if not FindRuinFeatures() then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: No usable map-dressing features were found in features/ruins/."
        )
        return
    end

    local positions = {}
    local created = 0
    local placementFailures = 0

    for i = 1, targetCount do
        local x, z =
            FindMapDressingPosition(
                beacons,
                camps,
                positions
            )

        if not x then
            placementFailures =
                placementFailures + 1
        else
            local featureID =
                SpawnMapRuin(x, z)

            if featureID then
                created = created + 1

                positions[
                    #positions + 1
                ] = {
                    x = x,
                    z = z,
                }
            end
        end
    end

    Debug(
        "Random map dressing:",
        created,
        "debris features from",
        targetCount,
        "density sites; placement failures",
        placementFailures
    )
end

--------------------------------------------------------------------------------
-- Template camp placement
--------------------------------------------------------------------------------

local function SpawnCampBuilding(
    x,
    z,
    heading
)
    if #buildingFeatureNames == 0 then
        return nil
    end

    local featureName =
        buildingFeatureNames[
            math.random(
                1,
                #buildingFeatureNames
            )
        ]

    return Spring.CreateFeature(
        featureName,
        x,
        Spring.GetGroundHeight(x, z),
        z,
        heading
    )
end

local function IsBuildingPositionClear(
    x,
    z,
    placedBuildingPositions
)
    local minimumDistanceSquared =
        CAMP_BUILDING_MIN_SPACING
        * CAMP_BUILDING_MIN_SPACING

    for i = 1,
        #placedBuildingPositions
    do
        local dx =
            x - placedBuildingPositions[i].x

        local dz =
            z - placedBuildingPositions[i].z

        if
            dx * dx + dz * dz
            < minimumDistanceSquared
        then
            return false
        end
    end

    return true
end

local function TransformSocket(
    camp,
    socket,
    rotation
)
    local localX =
        socket.x

    local localZ =
        socket.z

    local cosRotation =
        math.cos(rotation)

    local sinRotation =
        math.sin(rotation)

    local rotatedX =
        localX * cosRotation
        - localZ * sinRotation

    local rotatedZ =
        localX * sinRotation
        + localZ * cosRotation

    local worldX =
        camp.x + rotatedX

    local worldZ =
        camp.z + rotatedZ

    local heading =
        RadiansToHeading(
            rotation
            + DegreesToRadians(
                socket.facing
            )
        )

    return worldX, worldZ, heading
end

local function CampFootprintFitsMap(
    camp,
    template
)
    -- Conservative radius around the entire square decal. This is independent
    -- of rotation and keeps every corner inside the playable map.
    local halfWidth =
        template.width
        * 0.5

    local halfHeight =
        template.height
        * 0.5

    local radius =
        math.sqrt(
            halfWidth * halfWidth
            + halfHeight * halfHeight
        )

    return
        camp.x - radius >= 0
        and camp.x + radius <= Game.mapSizeX
        and camp.z - radius >= 0
        and camp.z + radius <= Game.mapSizeZ
end

local function SendCampDecal(
    camp,
    templateName,
    template,
    rotation
)
    local tintR,
        tintG,
        tintB,
        tintA =
        ResolveCampTint(
            camp,
            template
        )

    SendToUnsynced(
        CAMP_DECAL_ACTION,
        templateName,
        camp.x,
        camp.z,
        template.width * 0.5,
        template.height * 0.5,
        rotation,
        tintR,
        tintG,
        tintB,
        tintA,
        template.alpha or 0.72
    )
end

local function PlaceCamp(
    camp,
    campNumber,
    placedBuildingPositions
)
    if
        type(camp) ~= "table"
        or type(camp.x) ~= "number"
        or type(camp.z) ~= "number"
    then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: Camp",
            campNumber,
            "has invalid or missing x/z coordinates."
        )
        return 0
    end

    local templateName,
        template =
        ResolveCampTemplate(camp)

    if not template then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: Camp",
            campNumber,
            "could not resolve a camp template."
        )
        return 0
    end

    local rotation =
        ResolveCampRotation(camp)

    if not CampFootprintFitsMap(
        camp,
        template
    ) then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: Camp",
            campNumber,
            "template footprint extends outside the playable map; camp skipped."
        )
        return 0
    end

    local buildingCount =
        ResolveCampBuildingCount(
            template
        )

    local socketOrder =
        ShuffleCopy(
            template.sockets
        )

    local created = 0
    local rejected = 0

    for i = 1, buildingCount do
        local socket =
            socketOrder[i]

        local x,
            z,
            heading =
            TransformSocket(
                camp,
                socket,
                rotation
            )

        if
            x < 0
            or x > Game.mapSizeX
            or z < 0
            or z > Game.mapSizeZ
            or Spring.GetGroundHeight(x, z) < 0
            or not IsBuildingPositionClear(
                x,
                z,
                placedBuildingPositions
            )
        then
            rejected = rejected + 1
        else
            local featureID =
                SpawnCampBuilding(
                    x,
                    z,
                    heading
                )

            if featureID then
                created = created + 1

                placedBuildingPositions[
                    #placedBuildingPositions + 1
                ] = {
                    x = x,
                    z = z,
                }
            else
                rejected = rejected + 1
            end
        end
    end

    -- The decal is still useful when one socket was rejected by terrain or
    -- spacing, but do not draw an empty camp if nothing could be created.
    if created > 0 then
        SendCampDecal(
            camp,
            templateName,
            template,
            rotation
        )
    end

    Debug(
        "Camp",
        campNumber,
        "template",
        templateName,
        "at",
        camp.x,
        camp.z,
        "rotation(deg)",
        math.floor(
            rotation * 180 / math.pi
            + 0.5
        ),
        "requested",
        buildingCount,
        "buildings; created",
        created,
        "rejected",
        rejected
    )

    return created
end

local function PlaceCamps(camps)
    if #camps == 0 then
        return
    end

    if not FindBuildingFeatures() then
        Spring.Echo(
            "[Map Debris & Template Camps] WARNING: Camps exist but no usable buildings were found in features/buildings/."
        )
        return
    end

    local totalCreated = 0
    local placedBuildingPositions = {}

    for i = 1, #camps do
        totalCreated =
            totalCreated
            + PlaceCamp(
                camps[i],
                i,
                placedBuildingPositions
            )
    end

    Debug(
        "Created",
        totalCreated,
        "buildings across",
        #camps,
        "template camps."
    )
end

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------

local function PlaceMapFeatures()
    if placed then
        return
    end

    placed = true

    local beacons =
        FindNavBeacons()

    local camps =
        LoadCamps()

    PlaceMapDressing(
        beacons,
        camps
    )

    PlaceCamps(
        camps
    )
end

--------------------------------------------------------------------------------
-- Call-ins
--------------------------------------------------------------------------------

function gadget:GameFrame(frame)
    if frame == 5 then
        PlaceMapFeatures()
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
