local NARCSpot = {
	name              	= "NARC",
	description         = "Radar Homing Beacon",
	objectName        	= "Missile.s3o",
	script				= "NARCSpot.cob",
	category 			= "dontshoot",
	sightDistance       = 500,
	radarDistance      	= 500,
		activateWhenBuilt   = true,
	stealth				= 1,
	maxDamage           = 5000,
	mass                = 1,
	footprintX			= 1,
	footprintZ 			= 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 1,
	buildTime           = 0,
		maxSlope		= 20000,
		maxWaterdepth 	= 20000,
		
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		},

    customparams = {
    },
}

return lowerkeys({ ["NARCSpot"] = NARCSpot })