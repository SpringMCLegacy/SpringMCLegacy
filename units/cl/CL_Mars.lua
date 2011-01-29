local CL_Mars = {
	name              	= "Mars",
	description         = "Heavy Assault/Support Tank",
	objectName        	= "CL_Mars.s3o",
	script				= "CL_Mars.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 15000,--11500
	mass                = 10000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "38 26 48",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
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
    },
}

return lowerkeys({ ["CL_Mars"] = CL_Mars })