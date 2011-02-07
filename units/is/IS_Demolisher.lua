local IS_Demolisher = {
	name              	= "Demolisher",
	description         = "Heavy Assault Tank",
	objectName        	= "IS_Demolisher.s3o",
	script				= "IS_Demolisher.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 15000,
	mass                = 8000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "32 20 45",
	collisionVolumeOffsets = "0 5 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 8,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 4000,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.6, --54kph/10/2
		maxReverseVelocity= 1.3,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 425,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "AC20",
			},
			[2] = {
				name	= "AC20",
				weaponslaveto2 = 1,
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:LARGE_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x AC/20 - Armor: 13 tons",
    },
}

return lowerkeys({ ["IS_Demolisher"] = IS_Demolisher })