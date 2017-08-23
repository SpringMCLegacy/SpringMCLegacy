local Outpost_Seismic = Outpost:New{
	name              	= "Seismic Listening Post",
	description         = "Long-Range Seismic Sensor",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 10000,

	collisionVolumeScales = [[25 25 25]],

	seismicdistance 	= 5000,
	
	customparams = {
		helptext		= "Ping Pong Potato",
    },
	sounds = {
	select = "Seismic",
	}
}

return lowerkeys({ ["outpost_Seismic"] = Outpost_Seismic })