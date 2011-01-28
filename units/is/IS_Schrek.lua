local IS_Schrek = {
	name              	= "Schrek",
	description         = "Fire Support Tank",
	objectName        	= "IS_Schrek.s3o",
	script				= "IS_Schrek.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 7000,
	mass                = 4500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 20 46",
	collisionVolumeOffsets = "0 -1 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.7, --54kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "PPC",
			},
			[2] = {
				name	= "PPC",
			},
			[3] = {
				name	= "PPC",
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
    },
}

return lowerkeys({ ["IS_Schrek"] = IS_Schrek })