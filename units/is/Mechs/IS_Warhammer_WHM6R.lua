local IS_Warhammer_WHM6R = {
	name              	= "Warhammer WHM-6R",
	description         = "Heavy-class Mid Range Fire Support",
	objectName        	= "IS_Warhammer_WHM6R.s3o",
	iconType			= "heavymech",
	script				= "Mech.lua",
	corpse				= "IS_Warhammer_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 16000,
	mass                = 7000,
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
	buildCostEnergy     = 70,
	buildCostMetal      = 24000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 3, --60kph/2
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "PPC",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "PPC",
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
				name	= "MBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "SBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "SBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[7] = {
				name	= "MG",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[8] = {
				name	= "MG",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[9] = {
				name	= "SRM6",
				--mainDir = "0 0 1",
				--maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:PPC_MUZZLEFLASH",
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x PPC, 2 x Medium Beam Laser, 2 x Small Beam Laser, 2 x Machinegun, 1 x SRM-6 - Armor: 10 tons Standard",
		heatlimit		= "18",
		torsoturnspeed	= "120",
		unittype		= "mech",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({ ["IS_Warhammer_WHM6R"] = IS_Warhammer_WHM6R })