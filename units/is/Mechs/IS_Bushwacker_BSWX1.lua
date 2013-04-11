local IS_Bushwacker_BSWX1 = {
	name              	= "Bushwacker BSW-X1",
	description         = "Medium-class Mid Range Fire Support",
	objectName        	= "IS_Bushwacker_BSWX1.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Bushwacker_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 16100,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 40 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 20100,
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
				name	= "AC10",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERLBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "MG",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "MG",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "LRM5",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "LRM5",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:AC10_MUZZLEFLASH",
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x AC/10, 1 x Large Beam Laser, 2 x Machinegun, 2 x LRM-5 - Armor: 9 tons Ferro-Fibrous",
		heatlimit		= "22",
		torsoturnspeed	= "160",
		rightarmid 		= "6",
		unittype		= "mech",
		maxammo 		= {lrm = 180, ac10 = 20},
    },
}

return lowerkeys({ ["IS_Bushwacker_BSWX1"] = IS_Bushwacker_BSWX1 })