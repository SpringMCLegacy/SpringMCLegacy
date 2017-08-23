local Outpost_TurretControl = Outpost:New{
	name              	= "A.I. Turret Control",
	description         = "Automated Turret Control Station",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 8000,

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
	sounds = {
	select = "TurretControl",
	}
}

return lowerkeys({ ["outpost_TurretControl"] = Outpost_TurretControl })