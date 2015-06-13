local Upgrade_Garrison = Upgrade:New{
	name              	= "Garrison",
	description         = "Fortified Defensive Upgrade",
	objectName        	= "Upgrade_Bunker.s3o",
	maxDamage           = 50000,
	mass                = 10000,
	collisionVolumeScales = [[50 50 50]],
	buildCostMetal      = 5000,

	customparams = {
		helptext		= "Heavily-fortified structure resilient to all attacks to fortify captured control points.",
		flagdefendrate = 100,
		ignoreatbeacon	= false,
    },
}

return lowerkeys({ ["Upgrade_Garrison"] = Upgrade_Garrison })