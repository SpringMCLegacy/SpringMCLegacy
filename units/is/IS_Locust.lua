local IS_Locust = {
	name              	= "Locust",
	description         = "Light Scout Mech",
	objectName        	= "IS_Locust.s3o",
	script				= "IS_Locust.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
	maxDamage           = 3000,
	mass                = 2000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "15 35 15",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 6.5, --130kph/10/2
		maxReverseVelocity= 3.0,
		acceleration    = 2.0,
		brakeRate       = 0.5,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "SRM6",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "SRM6",
				--weaponSlaveTo3 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
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
		helptext		= "Armament: 1 x Medium Beam Laser, 2 x SRM-6 - Armor: 3 tons",
    },
}

return lowerkeys({ ["IS_Locust"] = IS_Locust })