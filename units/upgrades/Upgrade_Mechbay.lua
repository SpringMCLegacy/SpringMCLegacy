local Upgrade_Mechbay = {
	name              	= "Mobile Mech-Bay",
	description         = "Repair & Rearm Upgrade",
	objectName        	= "Upgrade_Mechbay.s3o",
	script				= "Upgrade.lua",
	iconType			= "beacon",
	category 			= "structure ground notbeacon",
	--activateWhenBuilt   = true,
	maxDamage           = 10000,
	mass                = 9000,
	footprintX			= 8,
	footprintZ 			= 8,
	collisionVolumeType = "box",
	collisionVolumeScales = "75 75 75",
	collisionVolumeOffsets = "0 0 0",
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	energyStorage		= 0,
	metalMake			= 0,
	metalStorage		= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	cantbetransported	= false,

	builder				= true,
	moveState			= 0,
		showNanoFrame		= 0,
		showNanoSpray		= 0,
		workerTime			= 1,
		canBeAssisted	= false,
	
	customparams = {
		dontcount		= 1,
		helptext		= "Repairs and re-arms Mechs and Vehicles.",
    },
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["Upgrade_Mechbay"] = Upgrade_Mechbay })