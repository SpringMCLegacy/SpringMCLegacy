local CL_Hephaestus = {
	name              	= "Hephaestus",
	description         = "Light Scout Hovercraft",
	objectName        	= "CL_Hephaestus.s3o",
	script				= "CL_Hephaestus.lua",
	explodeAs          	= "mechexplode",
	category 			= "tank ground hovercraft notbeacon",
	stealth				= 1,
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
--	radarDistanceJam    = 0,
	maxDamage           = 1250,
	mass                = 3000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "18 15 40",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 650,
	buildTime           = 0,
	canMove				= true,
	canHover			= true,
		movementClass   = "HOVER",
		maxVelocity		= 4.3, --130kph/30
		maxReverseVelocity= 4.05,
		acceleration    = .85,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CERMBL",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CERMBL",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "NARC",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Medium Pulse Laser, 1 x NARC Launcher - Armor: 5 tons",
    },
}

return lowerkeys({ ["CL_Hephaestus"] = CL_Hephaestus })