local IS_Osiris = {
	name              	= "Osiris",
	description         = "Light Skirmish Mech",
	objectName        	= "IS_Osiris.s3o",
	script				= "IS_Osiris.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 4500,
	mass                = 3000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "15 35 15",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 2000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 6.5, --130kph/10/2
		maxReverseVelocity= 3.0,
		acceleration    = 2.0,
		brakeRate       = 0.1,
		turnRate 		= 1000,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "ERSBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "MPL",
				--weaponSlaveTo3 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "MPL",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "MPL",
				--weaponSlaveTo5 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[6] = {
				name	= "MG",
				--weaponSlaveTo5 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[7] = {
				name	= "SRM6",
				--weaponSlaveTo5 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:SMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		"custom:RocketTrail",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 3 x Medium Pulse Laser, 2 x ER Small Beam Laser, 1 x MG, 1 x SRM-6 - Armor: 4 tons",
    },
}

return lowerkeys({ ["IS_Osiris"] = IS_Osiris })