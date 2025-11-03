function widget:GetInfo()
	return {
		name    = "Decal Drawer",
		desc    = "Draws the indicated decal top left corner of the map",
		author  = "",
		date    = "2025-06-10",
		license = "GPLv2",
		layer   = 0,
		enabled = false,
	}
end

-- NOTE: Texture must be part of the decal atlas (e.g., used in unitdefs or sfx)
-- Use `/dumpatlas decal` to get an output of the actual decal atlas

-- This is just debug code so that we can see what decals are in the index (outputs to infolog)
for k,v in pairs(Spring.GetGroundDecalTextures()) do Spring.Echo("[Decal Drawer] maindecal",k,v) end
for k,v in pairs(Spring.GetGroundDecalTextures(nil,false)) do Spring.Echo("[Decal Drawer] normdecal",k,v) end

local decalTexture = "maindecal_4"
local decalTextureNormal = "normdecal_4"
local decalSize = 85

local decalIDs = {}

function widget:Initialize()

	local decalID = Spring.CreateGroundDecal()
	if decalID then
		Spring.SetGroundDecalPosAndDims(decalID, 100, 100, decalSize, decalSize)

		--Random Rotation
		--local angle = math.random() * 2 * math.pi
		--Spring.SetGroundDecalRotation(decalID, angle)

		Spring.SetGroundDecalTexture(decalID, decalTexture, true)
		Spring.SetGroundDecalTexture(decalID, decalTextureNormal, false)
		Spring.SetGroundDecalAlpha(decalID, 1.0, 0.0)
		Spring.SetGroundDecalTint(decalID, 0.5, 0.5, 0.5, 0.5) -- neutral tint
		table.insert(decalIDs, decalID)

	end
end

function widget:Shutdown()
	for _, id in ipairs(decalIDs) do
		Spring.DestroyGroundDecal(id)
	end
end
