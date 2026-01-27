local Outpost_Mechbay = Outpost:New{
	name              	= "Mech Bay Facility",
	description         = "An outpost that can repair, resupply & customize mechs",
	iconType			= "outpost_mechbay",
	maxDamage           = 5500,
	mass                = 9000,
	buildCostMetal      = 7400,
		
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 200,
	
	customparams = {
		helptext		= "Repairs and re-arms Mechs and Vehicles.",
    },
	sounds = {
		select = "Mechbay",
	}
}

return lowerkeys({ ["outpost_Mechbay"] = Outpost_Mechbay })