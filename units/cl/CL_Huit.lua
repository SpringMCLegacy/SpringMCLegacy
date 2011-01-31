local CL_Huit = {
	name              	= "Huitzilopochtli",
	description         = "Artillery Vehicle",
	objectName        	= "CL_Huit.s3o",
	script				= "CL_Huit.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
	maxDamage           = 5500,
	mass                = 8500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "24 18 38",
	collisionVolumeOffsets = "0 1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 8.5,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 22,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.6, --32kph/10/2
		maxReverseVelocity= 0.8,
		acceleration    = 0.9,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArrowIV",
			},
			[2] = {
				name	= "ArrowIV",
			},
			[3] = {
				name	= "CMPL",
			},
			[3] = {
				name	= "CMPL",
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:LARGE_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Arrow IV Artillery Missle, 2 x Medium Pulse Laser - Armor: 5.5 tons",
    },
}

return lowerkeys({ ["CL_Huit"] = CL_Huit })