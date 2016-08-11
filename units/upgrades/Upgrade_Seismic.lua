local Upgrade_Seismic = Upgrade:New{
	name              	= "Seismic Listening Post",
	description         = "Long-Range Seismic Sensor",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 15000,

	collisionVolumeScales = [[25 25 25]],

	-- Constructor stuff
	builder				= true,
	builddistance 		= 1000000,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	
	customparams = {
		helptext		= "Ping Pong Potato",
    },
}

return lowerkeys({ ["Upgrade_Seismic"] = Upgrade_Seismic })