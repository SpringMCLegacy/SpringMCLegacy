local Decal = Unit:New{
	objectName 				= "blank.s3o",
	script 					= "decal.lua",
	useBuildingGroundDecal 	= true,
	hideDamage				= true,
	
	customParams = {
		decal = true,
	}
}

local Decal_Beacon = Decal:New{
	buildingGroundDecalType = "Scorch.png",
	buildingGroundDecalSizeX = 8,
	buildingGroundDecalSizeY = 8,
}

local Decal_Drop = Decal:New{
	buildingGroundDecalType = "Scorch2.png",
	buildingGroundDecalSizeX = 30,
	buildingGroundDecalSizeY = 30,
}

return lowerkeys({ 
	["Decal_Beacon"] = Decal_Beacon,
	["Decal_Drop"] = Decal_Drop,
})