local IS_LRMCarrier = {
	name              	= "LRM Carrier",
	description         = "Support Vehicle",
	objectName        	= "IS_LRMCarrier.s3o",
	script				= "IS_LRMCarrier.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 2000,
	mass                = 6000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 25 38",
	collisionVolumeOffsets = "0 2 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.7, --54kph/10/2
		maxReverseVelocity= 1.35,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 300,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LRM20",
			},
			[2] = {
				name	= "LRM20",
			},
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

return lowerkeys({ ["IS_LRMCarrier"] = IS_LRMCarrier })