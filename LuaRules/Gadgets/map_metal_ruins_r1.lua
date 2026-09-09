--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Metal Deposit Ruins
--
--  Detects discrete metal deposits on the map and places one randomized
--  ruin feature over each deposit.
--
--  Ruin FeatureDefs are discovered automatically from:
--
--      features/ruins/
--
--  The gadget does NOT care:
--      - what the files are named
--      - what the FeatureDefs are named
--      - how many ruin files exist
--      - whether one file contains multiple FeatureDefs
--
--  Revision 1:
--      - Adds configurable Nav Beacon exclusion radius.
--      - Ruins are not placed within NAV_BEACON_EXCLUSION_RADIUS elmos
--        of any existing MCL "beacon" unit.
--      - Placement runs on frame 5 so Lua-created Nav Beacons can initialize
--        before the exclusion scan.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
    return {
        name      = "Metal Deposit Ruins",
        desc      = "Places randomized ruin features over map metal deposits",
        author    = "zvero + ChatGPT",
        date      = "2026",
        license   = "GPL v2 or later",
        layer     = 0,
        enabled   = true,
    }
end

--------------------------------------------------------------------------------
-- Synced only
--------------------------------------------------------------------------------

if not gadgetHandler:IsSyncedCode() then
    return false
end

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local RUINS_FOLDER = "features/ruins/"

-- Any metal-map cell with a metal value greater than this counts as metal.
-- Leave at 0 for normal maps.
local METAL_THRESHOLD = 0

-- Deposits whose summed metal amount is <= this value are ignored.
-- Leave at 0 unless you encounter tiny stray metal pixels on some maps.
local MIN_DEPOSIT_METAL = 0

-- If true, diagonally touching metal cells are treated as belonging to
-- the same deposit.
local USE_DIAGONAL_CONNECTIONS = true

-- Give each ruin a randomized heading.
local RANDOMIZE_HEADING = true

-- No ruin may be placed within this horizontal radius of a Nav Beacon.
local NAV_BEACON_EXCLUSION_RADIUS = 300

-- MCL Nav Beacon UnitDef key.
local NAV_BEACON_UNITDEF_NAME = "beacon"

-- Diagnostic output to infolog.txt.
local DEBUG = true

--------------------------------------------------------------------------------
-- Localized API
--------------------------------------------------------------------------------

local spEcho            = Spring.Echo
local spGetMetalMapSize = Spring.GetMetalMapSize
local spGetMetalAmount  = Spring.GetMetalAmount
local spGetGroundHeight = Spring.GetGroundHeight
local spCreateFeature   = Spring.CreateFeature
local spGetAllUnits     = Spring.GetAllUnits
local spGetUnitDefID    = Spring.GetUnitDefID
local spGetUnitPosition = Spring.GetUnitPosition

local random = math.random
local lower  = string.lower
local type   = type
local pairs  = pairs

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local ruinsSpawned = false
local ruinFeatureNames = {}

--------------------------------------------------------------------------------
-- Debug
--------------------------------------------------------------------------------

local function Debug(...)
    if DEBUG then
        spEcho("[Metal Deposit Ruins]", ...)
    end
end

--------------------------------------------------------------------------------
-- Feature discovery
--------------------------------------------------------------------------------

local function FindRuinFeatures()
    ruinFeatureNames = {}

    local files = VFS.DirList(
        RUINS_FOLDER,
        "*.lua",
        VFS.GAME
    )

    if not files or #files == 0 then
        spEcho(
            "[Metal Deposit Ruins] ERROR: No .lua files found in",
            RUINS_FOLDER
        )

        return false
    end

    Debug("Found", #files, "ruin definition files.")

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
            spEcho(
                "[Metal Deposit Ruins] WARNING: Failed to inspect ruin file:",
                path
            )

            spEcho(
                "[Metal Deposit Ruins] VFS.Include error:",
                returnedDefs
            )

        elseif type(returnedDefs) ~= "table" then
            spEcho(
                "[Metal Deposit Ruins] WARNING:",
                path,
                "did not return a FeatureDef table."
            )

        else
            local definitionsInFile = 0

            for featureName, featureDef in pairs(returnedDefs) do
                if
                    type(featureName) == "string"
                    and type(featureDef) == "table"
                then
                    local normalizedName = lower(featureName)

                    if FeatureDefNames[normalizedName] then
                        if not alreadyAdded[normalizedName] then
                            alreadyAdded[normalizedName] = true

                            ruinFeatureNames[#ruinFeatureNames + 1] =
                                normalizedName

                            definitionsInFile = definitionsInFile + 1

                            Debug(
                                "Registered ruin:",
                                normalizedName,
                                "from",
                                path
                            )
                        end
                    else
                        Debug(
                            "Ignoring table",
                            featureName,
                            "from",
                            path,
                            "because no loaded FeatureDef matches it."
                        )
                    end
                end
            end

            if definitionsInFile == 0 then
                spEcho(
                    "[Metal Deposit Ruins] WARNING: No loaded FeatureDefs",
                    "were discovered in",
                    path
                )
            end
        end
    end

    if #ruinFeatureNames == 0 then
        spEcho(
            "[Metal Deposit Ruins] ERROR: No valid ruin FeatureDefs found in",
            RUINS_FOLDER
        )

        return false
    end

    Debug(
        "Ruin discovery complete:",
        #ruinFeatureNames,
        "spawnable FeatureDefs."
    )

    return true
end

--------------------------------------------------------------------------------
-- Metal deposit detection
--------------------------------------------------------------------------------

local function DetectMetalDeposits()
    local metalMapX, metalMapZ = spGetMetalMapSize()

    if not metalMapX or not metalMapZ then
        spEcho(
            "[Metal Deposit Ruins] ERROR: Spring.GetMetalMapSize() failed."
        )

        return {}
    end

    local cellSize = Game.metalMapSquareSize or 16

    Debug(
        "Scanning metal map:",
        metalMapX,
        "x",
        metalMapZ,
        "cells; cell size:",
        cellSize
    )

    local metal = {}
    local visited = {}

    local function Index(x, z)
        return z * metalMapX + x + 1
    end

    local metalCellCount = 0

    for z = 0, metalMapZ - 1 do
        for x = 0, metalMapX - 1 do
            local amount = spGetMetalAmount(x, z) or 0

            if amount > METAL_THRESHOLD then
                metal[Index(x, z)] = amount
                metalCellCount = metalCellCount + 1
            end
        end
    end

    Debug("Metal-bearing cells:", metalCellCount)

    if metalCellCount == 0 then
        return {}
    end

    local neighbours

    if USE_DIAGONAL_CONNECTIONS then
        neighbours = {
            {-1, -1},
            { 0, -1},
            { 1, -1},

            {-1,  0},
            { 1,  0},

            {-1,  1},
            { 0,  1},
            { 1,  1},
        }
    else
        neighbours = {
            { 0, -1},
            {-1,  0},
            { 1,  0},
            { 0,  1},
        }
    end

    local deposits = {}

    for startZ = 0, metalMapZ - 1 do
        for startX = 0, metalMapX - 1 do

            local startIndex = Index(startX, startZ)

            if metal[startIndex] and not visited[startIndex] then

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
                        local worldX = (x + 0.5) * cellSize
                        local worldZ = (z + 0.5) * cellSize

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

                                    queueLast =
                                        queueLast + 1

                                    queueX[queueLast] =
                                        nx

                                    queueZ[queueLast] =
                                        nz
                                end
                            end
                        end
                    end
                end

                if
                    totalMetal > MIN_DEPOSIT_METAL
                    and totalMetal > 0
                then
                    deposits[#deposits + 1] = {
                        x =
                            weightedX / totalMetal,

                        z =
                            weightedZ / totalMetal,

                        totalMetal =
                            totalMetal,

                        cells =
                            cellCount,
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

    local beaconDef = UnitDefNames[NAV_BEACON_UNITDEF_NAME]

    if not beaconDef then
        spEcho(
            "[Metal Deposit Ruins] WARNING: Nav Beacon UnitDef not found:",
            NAV_BEACON_UNITDEF_NAME
        )

        return beacons
    end

    local beaconDefID = beaconDef.id
    local units = spGetAllUnits()

    for i = 1, #units do
        local unitID = units[i]

        if spGetUnitDefID(unitID) == beaconDefID then
            local x, _, z = spGetUnitPosition(unitID)

            if x and z then
                beacons[#beacons + 1] = {
                    x = x,
                    z = z,
                }

                Debug(
                    "Found Nav Beacon at",
                    x,
                    z
                )
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

local function IsInsideNavBeaconExclusion(x, z, beacons)
    local radiusSq =
        NAV_BEACON_EXCLUSION_RADIUS
        * NAV_BEACON_EXCLUSION_RADIUS

    for i = 1, #beacons do
        local beacon = beacons[i]

        local dx = x - beacon.x
        local dz = z - beacon.z

        if dx * dx + dz * dz < radiusSq then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Feature placement
--------------------------------------------------------------------------------

local function SpawnRuinAtDeposit(deposit)
    if #ruinFeatureNames == 0 then
        return nil
    end

    local featureName =
        ruinFeatureNames[random(1, #ruinFeatureNames)]

    local x = deposit.x
    local z = deposit.z
    local y = spGetGroundHeight(x, z)

    local heading = 0

    if RANDOMIZE_HEADING then
        heading = random(0, 65535)
    end

    local featureID = spCreateFeature(
        featureName,
        x,
        y,
        z,
        heading
    )

    if featureID then
        Debug(
            "Created",
            featureName,
            "featureID",
            featureID,
            "at",
            x,
            y,
            z,
            "deposit metal:",
            deposit.totalMetal,
            "deposit cells:",
            deposit.cells
        )
    else
        spEcho(
            "[Metal Deposit Ruins] WARNING: Failed to create",
            featureName,
            "at",
            x,
            y,
            z
        )
    end

    return featureID
end

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------

local function SpawnMetalRuins()
    if ruinsSpawned then
        return
    end

    ruinsSpawned = true

    Debug("Starting metal ruin placement.")

    if not FindRuinFeatures() then
        return
    end

    local deposits = DetectMetalDeposits()

    if #deposits == 0 then
        Debug("No metal deposits detected.")
        return
    end

    local beacons = FindNavBeacons()

    local created = 0
    local excluded = 0

    for i = 1, #deposits do
        local deposit = deposits[i]

        if IsInsideNavBeaconExclusion(
            deposit.x,
            deposit.z,
            beacons
        ) then
            excluded = excluded + 1

            Debug(
                "Skipping metal deposit at",
                deposit.x,
                deposit.z,
                "- within",
                NAV_BEACON_EXCLUSION_RADIUS,
                "elmos of a Nav Beacon."
            )
        else
            if SpawnRuinAtDeposit(deposit) then
                created = created + 1
            end
        end
    end

    spEcho(
        "[Metal Deposit Ruins] Created",
        created,
        "ruins over",
        #deposits,
        "detected metal deposits;",
        excluded,
        "excluded by Nav Beacon radius;",
        #beacons,
        "Nav Beacons detected."
    )
end

--------------------------------------------------------------------------------
-- Call-ins
--------------------------------------------------------------------------------

function gadget:GameFrame(frame)
    -- Run shortly after initialization so MCL's Lua-created Nav Beacons
    -- already exist before ruin placement is evaluated.
    if frame == 5 then
        SpawnMetalRuins()
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
