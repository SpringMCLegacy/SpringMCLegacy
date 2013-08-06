local IS_Catapult_CPLTC1 = {
	name              	= "Catapult CPLT-C1",
	description         = "Heavy-class Long Range Missile Support",
	objectName        	= "IS_Catapult_CPLTC1.s3o",
	iconType			= "heavymech",
	script				= "Mech.lua",
	corpse				= "IS_Catapult_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 16000,
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
	buildCostEnergy     = 65,
	buildCostMetal        = 0,--      = 28820,
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
				name	= "LRM15",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "LRM15",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon ground",
				SlaveTo = 1,
			},
			[4] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon ground",
				SlaveTo = 1,
			},
			[5] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon ground",
				SlaveTo = 1,
			},
			[6] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon ground",
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
		helptext		= "Armament: 2 x LRM-15, 4 x Medium Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "15",
		torsoturnspeed	= "125",
		canjump			= "1",
		unittype		= "mech",
		maxammo 		= {lrm = 360},

    },
}

return lowerkeys({ ["IS_Catapult_CPLTC1"] = IS_Catapult_CPLTC1 })