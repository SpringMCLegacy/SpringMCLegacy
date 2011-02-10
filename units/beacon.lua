local beacon = {
	name              	= "Beacon",
	description         = "Strategic Marker",
	objectName        	= "beacon.s3o",
	script				= "beacon.lua",
	category 			= "beacon",
	sightDistance       = 0,
	radarDistance      	= 0,
		activateWhenBuilt   = true,
	maxDamage           = 50000,
	mass                = 1000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "4 25 4",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	energyStorage		= 0.01,
	metalMake			= 100,
	metalStorage		= 0,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	builder				= false,
		moveState			= 0,
		showNanoFrame		= 0,
		showNanoSpray		= 0,
		workerTime			= 1,
		canBeAssisted	= false,
	TEDClass			= METAL,
	
	sfxtypes = {
	},
	
	customparams = {
		ammosupplier	= "0",
		supplyradius	= "0",
		helptext		= "A Beacon indicating a strategically important location.",
    },
	
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["beacon"] = beacon })