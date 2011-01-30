local IS_Harasser = {
	name              	= "Harraser",
	description         = "Scout Hovercraft",
	objectName        	= "IS_Harasser.s3o",
	script				= "IS_Harasser.lua",
	category 			= "tank ground hovercraft",
	sightDistance       = 1000,
	radarDistance      	= 1500,
	maxDamage           = 1500,
	mass                = 2500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "20 15 30",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	canHover			= true,
		movementClass   = "HOVER",
		maxVelocity		= 8.1, --162kph/10/2
		maxReverseVelocity= 4.05,
		acceleration    = 1.0,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "SRM6",
			},
			[2] = {
				name	= "SRM6",
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:SMALL_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x SRM-6 - Armor: 1.5 tons",
    },
}

return lowerkeys({ ["IS_Harasser"] = IS_Harasser })