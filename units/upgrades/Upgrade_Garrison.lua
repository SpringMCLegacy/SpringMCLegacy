local Upgrade_Garrison = Upgrade:New{
	name              	= "Garrison",
	description         = "Fortified Defensive Upgrade",
	maxDamage           = 20000,
	mass                = 10000,
	collisionVolumeScales = [[50 50 50]],
	buildCostMetal      = 12000,

	-- Constructor stuff
	builder				= true,
	builddistance 		= 460, -- beacon cap radius
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	
	customparams = {
		helptext		= "Heavily-fortified structure resilient to all attacks to fortify captured control points.",
		flagdefendrate = 100,
		ignoreatbeacon	= false,
    },
}

return lowerkeys({ ["Upgrade_Garrison"] = Upgrade_Garrison })