local IS_Goblin = {
	name              	= "Goblin",
	description         = "Medium Tank",
	objectName        	= "IS_Goblin.s3o",
	script				= "IS_Goblin.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 8000,
	mass                = 4500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 18 36",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 3.2, --64kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LPL",
			},
			[2] = {
				name	= "MRM10",
			},
			[3] = {
				name	= "MG",
			},
			[4] = {
				name	= "MG",
			},
			--[5] = {
			--	name	= "LAMS",
			--},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:SMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
    },
}

return lowerkeys({ ["IS_Goblin"] = IS_Goblin })