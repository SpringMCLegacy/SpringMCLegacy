local Turret_LAMS = {
	name              	= "Weapon Emplacement",
	description         = "Laser AMS",
	objectName        	= "Turret_LAMS.s3o",
	script				= "Turret.lua",
	category 			= "structure notbeacon",
		activateWhenBuilt   = true,
	maxDamage           = 12000,
	mass                = 5000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 25 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	builder				= false,
	TEDClass			= "FORT",
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "AMS_Dropship",
				OnlyTargetCategory = "notbeacon",
			},
		},
	customparams = {
		ammosupplier	= "0",
		supplyradius	= "0",
		flagdefendrate	= "100",
		helptext		= "An auto-spawning defensive turret for Garrisons.",
		turretturnspeed = 360,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["Turret_LAMS"] = Turret_LAMS })