local IS_Owens = {
	name              	= "Owens",
	description         = "Light Support Mech",
	objectName        	= "IS_Owens.s3o",
	script				= "IS_Owens.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 7000,
	mass                = 3500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 35 15",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 3000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 5.0, --100kph/10/2
		maxReverseVelocity= 2.5,
		acceleration    = 1.75,
		brakeRate       = 0.1,
		turnRate 		= 900,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArtemisLRM5",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "ArtemisLRM5",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "NARC",
				--weaponSlaveTo3 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "MPL",
				--weaponSlaveTo3 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "MPL",
				--weaponSlaveTo3 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:SMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x NARC Launcher, 2 x Small Beam Laser, 2 x Artemis-enhanced LRM-5 - Armor: 7 tons",
    },
}

return lowerkeys({ ["IS_Owens"] = IS_Owens })