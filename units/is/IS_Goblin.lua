local IS_Goblin = {
	name              	= "Goblin",
	description         = "Medium Tank",
	objectName        	= "IS_Goblin.s3o",
	script				= "IS_Goblin.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
	maxDamage           = 6000,
	mass                = 4500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 18 36",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 4.5,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 1200,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 3.2, --64kph/10/2
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
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
				name	= "MG",
			},
			[4] = {
				name	= "MG",
			},
			--[5] = {
			--	name	= "LAMS",
			--},
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
		helptext		= "Armament: 1 x Large Pulse Laser, 1 x SRM-6, 2 x Machinegun, Laser Anti-Missile System - Armor: 8 tons",
    },
}

return lowerkeys({ ["IS_Goblin"] = IS_Goblin })