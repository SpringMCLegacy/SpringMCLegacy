local IS_Raven_RVN4L = {
	name              	= "Raven RVN-4L",
	description         = "Light ECM Scout Mech",
	objectName        	= "IS_Raven_RVN4L.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "IS_Raven_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
		radardistanceJam	= 500,
	maxDamage           = 9600,
	mass                = 3500,
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
	buildCostEnergy     = 35,
	buildCostMetal      = 13260,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.5, --90kph/30
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ERMBL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERMBL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "NARC",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "SRM6",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x ER Medium Beam Laser, 1 x SRM-6, 1 x NARC Launcher - Armor: 4.5 tons Ferro-Fibrous",
		heatlimit		= "11",
		torsoturnspeed	= "180",
		rightarmid 		= "4",
		unittype		= "mech",
		hasbap			= "true",
		hasecm			= "true",
		maxammo 		= {narc = 20, srm = 120},
    },
}

return lowerkeys({ ["IS_Raven_RVN4L"] = IS_Raven_RVN4L })