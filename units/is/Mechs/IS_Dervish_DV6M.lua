local IS_Dervish_DV6M = {
	name              	= "Dervish DV-6M",
	description         = "Medium Missile Support Mech",
	objectName        	= "IS_Dervish_DV6M.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Dervish_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 12000,
	mass                = 5500,
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
		maxVelocity		= 4, --80kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LRM10",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "LRM10",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "SRM2",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "SRM2",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x LRM-10, 2 x Medium Laser, 2 x SRM-2 - Armor: 7.5 tons Standard",
		heatlimit		= "10",
		torsoturnspeed	= "160",
		leftarmid		= "4",
		rightarmid 		= "3",
		unittype		= "mech",
		maxammo 		= {lrm = 360, srm = 240},
    },
}

return lowerkeys({ ["IS_Dervish_DV6M"] = IS_Dervish_DV6M })