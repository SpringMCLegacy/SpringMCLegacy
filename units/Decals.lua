local Decal = Unit:New{
	objectName 				= "Decal.s3o",
	script 					= "decal.lua",
	useBuildingGroundDecal 	= true,
	hideDamage				= true,
	maxDamage				= 10, -- hack to avoid showing healthbar, never actually takes damage
	
	customParams = {
		decal = true,
		ignoreatbeacon	= true,
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