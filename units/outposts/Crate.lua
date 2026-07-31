local Crate = Outpost:New{
	name              	= "Delivery Crate",
	description         = "A packing crate to deliver items from orbit.",
	maxDamage           = 10000,
	mass                = 10000,
	buildCostMetal      = 10520,
	script				= "Crate.lua",
	objectName			= "Outpost/Crate.s3o",
	
	footprintX			= 1,
	footprintZ 			= 1,
	collisionVolumeScales = [[0.1 0.1 0.1]],
	
	customparams = {
		baseclass		= "crate",
		ignoreatbeacon	= true,
		normaltex		= "unittextures/normals/Outpost_Aircon_Normals.dds",
    },
}

local CrateLong = Crate:New{
	objectName			= "Outpost/CrateLong.s3o",
}

return lowerkeys({ 
	["Crate"] = Crate,
	["CrateLong"] = CrateLong,
})