local CL_Oro = {
	name              	= "Oro",
	description         = "Combat Tank",
	objectName        	= "CL_Oro.s3o",
	script				= "CL_Oro.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 10000,--5500
	mass                = 6000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 16 35",
	collisionVolumeOffsets = "0 1 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 3.2, --64kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 400,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LBX20",
			},
			[2] = {
				name	= "LPL",
			},
			[3] = {
				name	= "CERMBL",
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
    },
}

return lowerkeys({ ["CL_Oro"] = CL_Oro })