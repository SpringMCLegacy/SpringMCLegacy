local IS_Hunchback_HBK4G = {
	name              	= "Hunchback HBK-4G",
	description         = "Medium-class Close Range Brawler",
	objectName        	= "IS_Hunchback_HBK4G.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Hunchback_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 16000,
	mass                = 5000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 50 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 21100,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 3, --60kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "AC20",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "SBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x AC/20, 2 x Medium Beam Laser, 1 x Small Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "13",
		torsoturnspeed	= "160",
		unittype		= "mech",
		maxammo 		= {ac20 = 16},
    },
}

return lowerkeys({ ["IS_Hunchback_HBK4G"] = IS_Hunchback_HBK4G })