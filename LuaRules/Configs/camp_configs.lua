--------------------------------------------------------------------------------
-- MCL Camp Templates
-- Author: zvero + ChatGPT
--
-- All camp-layout definitions live here.
--
-- Coordinate convention:
--     x = local east/west offset from camp centre
--     z = local north/south offset from camp centre
--     positive z = downward/southward in the source decal image
--
-- facing is in degrees relative to the unrotated template:
--      0 = +Z
--     90 = +X
--    180 = -Z
--    -90 = -X
--
-- A new template requires:
--     1. bitmaps/Decals/camps/<name>.png
--     2. one new entry in this table
--
--------------------------------------------------------------------------------

return {

    ---------------------------------------------------------------------------
    -- Template 1
    ---------------------------------------------------------------------------

    template1 = {
        texture =
            "bitmaps/Decals/camps/template1.png",

        width = 420,
        height = 420,
        referenceRadius = 600,
        dressingExclusionRadius = 266,

        buildingsMin = 5,
        buildingsMax = 6,

        -- Recoil ground-decal tint:
        -- 0.5 RGB is neutral/no hue shift.
        tint = {0.5, 0.5, 0.5, 0.5},
        alpha = 0.72,

        sockets = {
            -- upper-left
            {x = -109.6, z = -131.3, facing =  32},

            -- upper-right
            {x =  125.0, z = -137.9, facing = -28},

            -- right-middle
            {x =   81.9, z =  -35.7, facing = -23},

            -- lower-left
            {x = -112.3, z =   83.0, facing = 152},

            -- lower-centre
            {x =   14.4, z =  135.1, facing = 179},

            -- lower-right
            {x =  151.9, z =  141.8, facing = 195},
        },
    },

    ---------------------------------------------------------------------------
    -- Template 2
    --
    -- The current template2 image contains seven distinct building clearings.
    ---------------------------------------------------------------------------

    template2 = {
        texture =
            "bitmaps/Decals/camps/template2.png",

        width = 600,
        height = 600,
        referenceRadius = 600,
        dressingExclusionRadius = 380,

        buildingsMin = 6,
        buildingsMax = 7,

        tint = {0.5, 0.5, 0.5, 0.5},
        alpha = 0.72,

        sockets = {
            -- upper-left
            {x =  -99.0, z = -166.0, facing =   29},

            -- upper-right
            {x =   99.5, z = -162.7, facing =  -29},

            -- middle-left
            {x = -166.0, z =  -52.2, facing =   68},

            -- middle-right
            {x =  173.2, z =  -50.7, facing =  -69},

            -- lower-left
            {x = -189.5, z =  148.3, facing =  125},

            -- lower-centre
            {x =  -27.8, z =  205.3, facing =  171},

            -- lower-right
            {x =  143.1, z =  187.1, facing = -140},
        },
    },


    ---------------------------------------------------------------------------
    -- Template 3
    --
    -- Six-pad layout with three roads leaving the camp.
    ---------------------------------------------------------------------------

    template3 = {
        texture =
            "bitmaps/Decals/camps/template3.png",

        width = 600,
        height = 600,
        referenceRadius = 600,
        dressingExclusionRadius = 380,

        buildingsMin = 5,
        buildingsMax = 6,

        tint = {0.5, 0.5, 0.5, 0.5},
        alpha = 0.72,

        sockets = {
            -- upper-left
            {x =  -83.2, z =  -98.4, facing =   27},

            -- upper-right
            {x =   98.2, z =  -51.8, facing =  -43},

            -- middle-left
            {x = -121.4, z =   57.0, facing =   91},

            -- middle-right
            {x =  125.5, z =   64.2, facing =  -94},

            -- lower-left
            {x =  -70.8, z =  187.5, facing =  153},

            -- lower-right
            {x =   86.9, z =  190.6, facing = -146},
        },
    },

}
