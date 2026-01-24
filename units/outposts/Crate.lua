local Crate = Outpost:New{
	name              	= "Delivery Crate",
	description         = "A packing crate to deliver items from orbit.",
	maxDamage           = 10000,
	mass                = 10000,
	buildCostMetal      = 10520,
	script				= "Crate.lua",
	objectName			= "Outpost/Crate.s3o",
	
	customparams = {
		outpost 		= false, -- TODO: Check if this is needed
		baseclass		= "crate",
		ignoreatbeacon	= true,
    },
}

return lowerkeys({ ["Crate"] = Crate })