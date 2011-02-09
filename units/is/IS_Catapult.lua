local IS_Catapult = {
	name              	= "Catapult",
	description         = "Heavy Missile Support Mech",
	objectName        	= "IS_Catapult.s3o",
	script				= "IS_Catapult.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 10000,
	mass                = 6500,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "45 50 40",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 11000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 2.16, --65kph/30
		maxReverseVelocity= 1.0,
		acceleration    = 1,
		brakeRate       = 0.2,
		turnRate 		= 650,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArtemisLRM20",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "ArtemisLRM20",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "MPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "MPL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "MPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[6] = {
				name	= "MPL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		"custom:RocketTrail",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Artemis-enhanced LRM-20, 2 x Large Pulse Laser, 2 x Medium Pulse Laser - Armor: 8.5 tons",
    },
}

return lowerkeys({ ["IS_Catapult"] = IS_Catapult })