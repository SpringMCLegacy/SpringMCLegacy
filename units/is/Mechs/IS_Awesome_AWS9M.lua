local IS_Awesome_AWS9M = {
	name              	= "Awesome AWS-9M",
	description         = "Assault-class Long Range Fire Support/Sniper",
	objectName        	= "IS_Awesome_AWS9M.s3o",
	iconType			= "assaultmech",
	script				= "Mech.lua",
	corpse				= "IS_Awesome_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 24700,
	mass                = 8500,
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
	buildCostEnergy     = 85,
	buildCostMetal      = 35160,
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
				name	= "ERPPC",
				--mainDir = "0 0 1",
				--maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERPPC",
				--mainDir = "0 0 1",
				--maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "ERPPC",
				--mainDir = "0 0 1",
				--maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "SPL",
				--mainDir = "0 0 1",
				--maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "MPL",
				--mainDir = "0 0 1",
				--maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "SSRM4",
				--mainDir = "0 0 1",
				--maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:PPC_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 3 x ERPPC, 1 x MPL, 1 x SPL, 1 x SSRM-4 - Armor: 15.5 tons Standard",
		heatlimit		= "38",
		torsoturnspeed	= "100",
		unittype		= "mech",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({ ["IS_Awesome_AWS9M"] = IS_Awesome_AWS9M })