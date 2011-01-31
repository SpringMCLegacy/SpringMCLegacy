local CL_Mars = {
	name              	= "Mars",
	description         = "Heavy Assault/Support Tank",
	objectName        	= "CL_Mars.s3o",
	script				= "CL_Mars.lua",
	category 			= "tank ground",
	stealth				= 1,
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
	maxDamage           = 12000,--11500
	mass                = 10000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "38 27 52",
	collisionVolumeOffsets = "0 -1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 10,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Mars",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 7000,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.6, --32kph/10/2
		maxReverseVelocity= 1.5,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 400,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
			},
			[2] = {
				name	= "CERLBL",
			},
			[3] = {
				name	= "LBX10",
				mainDir = "0 0 1",
				maxAngleDif = 35,
			},
			[4] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 180,
			},
			[5] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 180,
			},
			[6] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 180,
			},
			[7] = {
				name	= "MG",
			},
			[8] = {
				name	= "MG",
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:LARGE_MUZZLEFLASH",
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle, 1 x ER Large Beam Laser, 1 x LBX/10, 3 x LRM-15 - Armor: 15 tons",
    },
}

return lowerkeys({ ["CL_Mars"] = CL_Mars })