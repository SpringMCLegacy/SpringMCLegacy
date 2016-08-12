local Upgrade_Seismic = Upgrade:New{
	name              	= "Seismic Listening Post",
	description         = "Long-Range Seismic Sensor",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 15000,

	collisionVolumeScales = [[25 25 25]],

	seismicdistance 	= 9000,
	
	customparams = {
		helptext		= "Ping Pong Potato",
    },
}

return lowerkeys({ ["Upgrade_Seismic"] = Upgrade_Seismic })