local IS_Atlas_AS7K = {
	name              	= "Atlas AS7-K",
	description         = "Assault-class Long Range Fire Support",
	objectName        	= "IS_Atlas_AS7K.s3o",
	iconType			= "assaultmech",
	script				= "Mech.lua",
	corpse				= "IS_Atlas_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 30400,
	mass                = 10000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "40 60 40",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 100, -- in tons
	buildCostMetal        = 0,--      = 38600,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 2.5, --50kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERLBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "ERLBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "MPL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "MPL",
				--mainDir = "0 0 1",
				--maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "LRM10",
				--mainDir = "0 0 1",
				--maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[7] = {
				name	= "LRM10",
				--mainDir = "0 0 1",
				--maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[8] = {
				name	= "AMS",
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:AC20_MUZZLEFLASH",
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss, 2 x Large Beam Laser, 2 x Medium Pulse Laser, 2 x LRM-10, AMS - Armor: 19 tons Standard",
		heatlimit		= "20",
		torsoturnspeed	= "100",
		unittype		= "mech",
		maxammo 		= {lrm = 360, gauss = 20},
    },
}

return lowerkeys({ ["IS_Atlas_AS7K"] = IS_Atlas_AS7K })