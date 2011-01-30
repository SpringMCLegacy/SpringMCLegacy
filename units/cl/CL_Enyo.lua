local CL_Enyo = {
	name              	= "Enyo",
	description         = "Medium Assault Tank",
	objectName        	= "CL_Enyo.s3o",
	script				= "CL_Enyo.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
	maxDamage           = 7000,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 25 35",
	collisionVolumeOffsets = "0 1 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 4.8, --97kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 0.9,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LPL",
			},
			[2] = {
				name	= "SRM6",
			},
			[3] = {
				name	= "SRM6",
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
		helptext		= "Armament: 1 x Large Pulse Laser, 2 x SRM-6 - Armor: 7 tons",
    },
}

return lowerkeys({ ["CL_Enyo"] = CL_Enyo })