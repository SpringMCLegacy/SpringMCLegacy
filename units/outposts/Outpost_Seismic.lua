local Outpost_Seismic = Outpost:New{
	name              	= "Seismic Listening Post",
	description         = "A long-range seismic detection sensor",
	iconType			= "outpost_sensors",
	maxDamage           = 5000,
	mass                = 5000,
	buildCostMetal      = 5350,

	seismicdistance 	= 5000,
	
	customparams = {
		helptext		= "Ping Pong Potato",
    },
	sounds = {
		select = "Seismic",
	}
}

--return lowerkeys({ ["outpost_Seismic"] = Outpost_Seismic })