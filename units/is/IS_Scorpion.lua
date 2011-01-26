local IS_Scorpion = {
	name              	= "Scorpion",
	description         = "Light Tank",
	objectName        	= "IS_Scorpion.s3o",
	script				= "IS_Scorpion.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 2000,
	mass                = 2500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "20 10 30",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 3.2, --64kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 1.0,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LightGauss",
			},
			[2] = {
				name	= "MG",
				weaponslaveto2 = 1,
			},
			[3] = {
				name	= "MG",
				weaponslaveto3 = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:SMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
    },
}

return lowerkeys({ ["IS_Scorpion"] = IS_Scorpion })