local IS_Avatar_AV1O = {
	name              	= "Avatar AV1-O",
	description         = "Heavy-class Mid Range Fire Support",
	objectName        	= "IS_Avatar_AV1O.s3o",
	iconType			= "heavymech",
	script				= "Mech.lua",
	corpse				= "IS_Avatar_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 19200,
	mass                = 6000,
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
	buildCostEnergy     = 65,
	buildCostMetal      = 28820,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 3, --60kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LBX10",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "MPL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "MPL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "LRM10",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[7] = {
				name	= "LRM10",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		"custom:JumpJetTrail",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x LBX-10, 2 x Medium Pulse Laser, 2 x Medium Beam Laser, 2 x LRM-10 - Armor: 12 tons Standard",
		heatlimit		= "20",
		torsoturnspeed	= "140",
		unittype		= "mech",
		hasbap			= "true",
		maxammo 		= {ac10 = 50, lrm = 360},

    },
}

return lowerkeys({ ["IS_Avatar_AV1O"] = IS_Avatar_AV1O })