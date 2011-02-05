local CL_Hephaestus = {
	name              	= "Hephaestus",
	description         = "Scout Hovercraft",
	objectName        	= "CL_Hephaestus.s3o",
	script				= "CL_Hephaestus.lua",
	category 			= "tank ground hovercraft",
	stealth				= 1,
	sightDistance       = 1000,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
--	radarDistanceJam    = 0,
	maxDamage           = 5000,
	mass                = 3000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "18 15 40",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 500,
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
			[3] = {
				name	= "NARC",
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
		helptext		= "Armament: 2 x Medium Pulse Laser - Armor: 5 tons",
    },
}

return lowerkeys({ ["CL_Hephaestus"] = CL_Hephaestus })