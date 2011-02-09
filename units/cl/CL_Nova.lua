local CL_Nova = {
	name              	= "Nova",
	description         = "Medium Skirmish Mech",
	objectName        	= "CL_Nova.s3o",
	script				= "CL_Nova.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 10000,
	mass                = 5000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 50 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 5000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.3, --86kph/10/2
		maxReverseVelocity= 2.85,
		acceleration    = 1.8,
		brakeRate       = 0.1,
		turnRate 		= 850,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CERMBL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "CERMBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "CERMBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "CERMBL",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "CERMBL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[6] = {
				name	= "CERMBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[7] = {
				name	= "CERMBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[8] = {
				name	= "CERMBL",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 8 x ER Medium Beam Laser - Armor: 10 tons",
    },
}

return lowerkeys({ ["CL_Nova"] = CL_Nova })