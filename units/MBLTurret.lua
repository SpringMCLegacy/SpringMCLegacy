local MBLTurret = {
	name              	= "Defense Turret",
	description         = "Dual Medium Lasers",
	objectName        	= "MBLTurret.s3o",
	script				= "Turret.lua",
	category 			= "structure notbeacon",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
	maxDamage           = 22000,
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
	maxSlope			= 50,
	builder				= false,
	TEDClass			= "FORT",
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ERMBL",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERMBL",
				OnlyTargetCategory = "notbeacon",
			},
		},
	customparams = {
		ammosupplier	= "0",
		supplyradius	= "0",
		helptext		= "An auto-spawning defensive turret for Garrisons.",
    },
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["MBLTurret"] = MBLTurret })