local Outpost_TurretControl = Outpost:New{
	name              	= "Turret Control (Defend)",
	description         = "Allows deployment of AI defense turrets around the beacon",
	maxDamage           = 7000,
	mass                = 5000,
	buildCostMetal      = 6600,

	-- Constructor stuff
	builder				= true,
	builddistance 		= 1000,
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