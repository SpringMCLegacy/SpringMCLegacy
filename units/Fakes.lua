local Fake = Unit:New{
	objectName 				= "Decal.s3o",
	script 					= "decal.lua",
	hideDamage				= true,
	maxDamage				= 10, -- hack to avoid showing healthbar, never actually takes damage
	
	customParams = {
		ignoreatbeacon	= true,
	}
}

local Narc_ECM = Fake:New{
	radarDistanceJam = 150,
	sightDistance = 150,
	
	customParams = {
		ecm = true,
		invincible = true,
	}
}

local Nuke_Icon = Fake:New{
	iconType = "nuke",
}

local Nuke_Meltdown = Fake:New{
	sightDistance = 32,
	airSightDistance = 32,
	customParams = {
		invincible = true,
	}
}

local Decal = Fake:New{
	useBuildingGroundDecal 	= true,
	customParams = {
		decal = true,
		invincible = true,
	}
}

local Decal_Beacon = Decal:New{
	buildingGroundDecalType = "Decals/Scorch.png",
	buildingGroundDecalSizeX = 8,
	buildingGroundDecalSizeY = 8,
}

local Decal_Drop = Decal:New{
	buildingGroundDecalType = "Decals/Scorch2.png",
	buildingGroundDecalSizeX = 30,
	buildingGroundDecalSizeY = 30,
}

return lowerkeys({ 
	["Narc_ECM"] = Narc_ECM,
	["Nuke_Icon"] = Nuke_Icon,
	["Nuke_Meltdown"] = Nuke_Meltdown,
	["Decal_Beacon"] = Decal_Beacon,
	["Decal_Drop"] = Decal_Drop,
})