local IS_Sniper = {
	name              	= "Sniper",
	description         = "Mobile Artillery",
	objectName        	= "IS_Sniper.s3o",
	script				= "IS_Sniper.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	maxDamage           = 4000,
	mass                = 8000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 20 40",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.6, --54kph/10/2
		maxReverseVelocity= 1.3,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 300,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Sniper",
				mainDir = "0 0 1",
				maxAngleDif = 15,
			},
			[2] = {
				name	= "ERSBL",
			},
			[3] = {
				name	= "ERSBL",
				weaponslaveto3 = 2,
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:XXLARGE_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
    },
}

return lowerkeys({ ["IS_Sniper"] = IS_Sniper })