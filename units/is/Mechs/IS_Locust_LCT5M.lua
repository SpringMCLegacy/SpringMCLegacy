local IS_Locust_LCT5M = {
	name              	= "Locust LCT-5M",
	description         = "Light Scout Mech",
	objectName        	= "IS_Locust_LCT5M.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "IS_Locust_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 7100,
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
	buildCostEnergy     = 20,
	buildCostMetal      = 9200,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 9, --180kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ERMBL",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x ER Medium Beam Laser, 4 x ER Small Beam Laser - Armor: 4 tons",
		heatlimit		= "10",
		torsoturnspeed	= "195",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Locust_LCT5M"] = IS_Locust_LCT5M })