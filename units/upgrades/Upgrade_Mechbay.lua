local Upgrade_Mechbay = Upgrade:New{
	name              	= "Mobile Mech-Bay",
	description         = "Repair & Rearm Upgrade",
	maxDamage           = 10000,
	mass                = 9000,
	buildCostMetal      = 5000,
		
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 100,
	
	customparams = {
		helptext		= "Repairs and re-arms Mechs and Vehicles.",
    },
}

return lowerkeys({ ["Upgrade_Mechbay"] = Upgrade_Mechbay })