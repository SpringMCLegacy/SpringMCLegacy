local CL_Warhawk = {
	name              	= "War Hawk (Masakari)",
	description         = "Assault-class Sniper Mech",
	objectName        	= "CL_Warhawk.s3o",
	script				= "CL_Warhawk.lua",
	category 			= "mech ground notbeacon",
	sightDistance       = 1500,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 13500,
	mass                = 8500,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "40 50 40",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 13500,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 2.13, --64kph/10/2
		maxReverseVelocity= 1.06,
		acceleration    = 1.0,
		brakeRate       = 0.15,
		turnRate 		= 700,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CERPPC",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CERPPC",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "CERPPC",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "CERPPC",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[5] = {
				name	= "LRM10",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 4 x ER Particle Cannon, 1 x LRM-10 - Armor: 19 tons",
    },
}

return lowerkeys({ ["CL_Warhawk"] = CL_Warhawk })