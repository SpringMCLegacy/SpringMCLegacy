local CL_Maddog = {
	name              	= "Mad Dog (Vulture)",
	description         = "Heavy Missile Support Mech",
	objectName        	= "CL_Maddog.s3o",
	script				= "CL_Maddog.lua",
	category 			= "mech ground",
	sightDistance       = 1500,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 8500,
	mass                = 6000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "40 50 40",
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
		maxVelocity		= 4.3, --86kph/10/2
		maxReverseVelocity= 1.10,
		acceleration    = 1,
		brakeRate       = 0.2,
		turnRate 		= 700,
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
				name	= "CLPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "CMPL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "CLPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[6] = {
				name	= "CMPL",
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
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Artemis-enhanced LRM-20, 2 x Large Pulse Laser, 2 x Medium Pulse Laser - Armor: 8.5 tons",
    },
}

return lowerkeys({ ["CL_Maddog"] = CL_Maddog })