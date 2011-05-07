local IS_Harasser = {
	name              	= "Harraser",
	description         = "Light Skirmish Hovercraft",
	objectName        	= "IS_Harasser.s3o",
	script				= "Vehicle.lua",
	corpse				= "IS_Harasser_X",
	explodeAs          	= "mechexplode",
	category 			= "tank ground hovercraft notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 2400,
	mass                = 2500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "20 15 30",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 25,
	buildCostMetal      = 4320,
	buildTime           = 0,
	canMove				= true,
	canHover			= true,
		movementClass   = "HOVER",
		maxVelocity		= 5.4, --162kph/30
		maxReverseVelocity= 4.05,
		acceleration    = 1.0,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "SRM6",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "SRM6",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x SRM-6 - Armor: 1.5 tons",
		heatlimit		= "10",
		unittype		= "vehicle",
		turretturnspeed = "100",
		elevationspeed  = "200",
    },
}

return lowerkeys({ ["IS_Harasser"] = IS_Harasser })