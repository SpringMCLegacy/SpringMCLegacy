local CL_Ares = {
	name              	= "Ares",
	description         = "Medium Tank",
	objectName        	= "CL_Ares.s3o",
	script				= "CL_Ares.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
	maxDamage           = 4500,
	mass                = 4000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 25 32",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 4.3, --86kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CERLBL",
			},
			[2] = {
				name	= "ATM9",
			},
			[3] = {
				name	= "ATM9",
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
		helptext		= "Armament: 1 x ER Large Beam Laser, 2 x ATM-9 - Armor: 4.5 tons",
    },
}

return lowerkeys({ ["CL_Ares"] = CL_Ares })