local Outpost_EWAR = Outpost:New{
	name              	= "EWAR Transmission Post",
	description         = "A powerful ECM outpost to jam enemy sensors",
	iconType			= "outpost_ewar",
	maxDamage           = 5000,
	mass                = 5000,
	buildCostMetal      = 5350,
	
	radarDistance		= 2500,
	radarDistanceJam	= 0,
	
	customparams = {
		ecm				= true,
    },
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_ewar"] = Outpost_EWAR })