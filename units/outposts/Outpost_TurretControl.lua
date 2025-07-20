local Outpost_TurretControl = Outpost:New{
	name              	= "Turret Control Hub",
	description         = "A control hub for automated defensive turrets (sold separately)",
	iconType			= "outpost_turretcontrol",
	maxDamage           = 7000,
	mass                = 5000,
	buildCostMetal      = 6600,

	-- Constructor stuff
	builder				= true,
	builddistance 		= 460 * 1.5,
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