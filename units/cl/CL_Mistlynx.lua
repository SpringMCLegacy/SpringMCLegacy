local CL_Mistlynx = {
	name              	= "Mist Lynx (Koshi)",
	description         = "Light Missile Support Mech",
	objectName        	= "CL_Mistlynx.s3o",
	script				= "CL_Mistlynx.lua",
	category 			= "mech ground notbeacon",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 2000,
	mass                = 2000,
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
	buildCostMetal      = 4000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.3, --130kph/30
		maxReverseVelocity= 2.15,
		acceleration    = 2.0,
		brakeRate       = 0.1,
		turnRate 		= 900,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LRM10",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "SSRM4",
				--weaponSlaveTo2 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "NARC",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "MG",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "MG",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
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
		helptext		= "Armament: 2 x ER Medium Beam Laser, 1 x SRM-4, 1 x SRM-6 - Armor: 2 tons",
    },
}

return lowerkeys({ ["CL_Mistlynx"] = CL_Mistlynx })