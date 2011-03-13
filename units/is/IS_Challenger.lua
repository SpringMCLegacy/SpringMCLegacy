local IS_Challenger = {
	name              	= "Challenger",
	description         = "Heavy Strike Tank",
	objectName        	= "IS_Challenger.s3o",
	script				= "IS_Challenger.lua",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 7000,
	mass                = 9000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "33 22 45",
	collisionVolumeOffsets = "0 5 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 9,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 32,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 5000,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.8, --54kph/30
		maxReverseVelocity= 1.3,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 425,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "LBX10",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "LRM10",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "MPL",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "MPL",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			--[6] = {
			--	name	= "LAMS",
			--},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:GAUSS_MUZZLEFLASH",
		"custom:AC10_MUZZLEFLASH",
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle, 1 x LBX/10, 1 x LRM-10, 2 x Medium Pulse Laser - Armor: 14 tons",
	},
}

return lowerkeys({ ["IS_Challenger"] = IS_Challenger })