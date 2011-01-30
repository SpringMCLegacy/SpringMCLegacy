local IS_LRMCarrier = {
	name              	= "LRM Carrier",
	description         = "Support Vehicle",
	objectName        	= "IS_LRMCarrier.s3o",
	script				= "IS_LRMCarrier.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 2000,
	maxDamage           = 2000,
	mass                = 6000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 25 38",
	collisionVolumeOffsets = "0 2 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 6,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 23,--width to render the decal
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
		helptext		= "Armament: 2 x LRM-20 - Armor: 2 tons",
    },
}

return lowerkeys({ ["IS_LRMCarrier"] = IS_LRMCarrier })