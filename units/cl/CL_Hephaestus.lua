local CL_Hephaestus = {
	name              	= "Hephaestus",
	description         = "Scout Hovercraft",
	objectName        	= "CL_Hephaestus.s3o",
	script				= "CL_Hephaestus.lua",
	category 			= "tank ground hovercraft",
	sightDistance       = 1000,
	maxDamage           = 5000,
	mass                = 3000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "18 15 30",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	canHover			= true,
		movementClass   = "HOVER",
		maxVelocity		= 6.5, --130kph/10/2
		maxReverseVelocity= 4.05,
		acceleration    = .85,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "MPL",
			},
			[2] = {
				name	= "MPL",
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
    },
}

return lowerkeys({ ["CL_Hephaestus"] = CL_Hephaestus })