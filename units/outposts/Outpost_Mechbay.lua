local Outpost_Mechbay = Outpost:New{
	name              	= "Mobile Mech-Bay",
	description         = "Repair & Rearm Outpost",
	maxDamage           = 10000,
	mass                = 9000,
	buildCostMetal      = 8000,
		
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 100,
	
	customparams = {
		helptext		= "Repairs and re-arms Mechs and Vehicles.",
    },
	sounds = {
	select = "Mechbay",
	}
}

return lowerkeys({ ["outpost_Mechbay"] = Outpost_Mechbay })