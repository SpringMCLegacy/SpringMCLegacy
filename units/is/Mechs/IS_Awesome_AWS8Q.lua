local IS_Awesome_AWS8Q = {
	name              	= "Awesome AWS-8Q",
	description         = "Assault-class Mid Range Fire Support",
	objectName        	= "IS_Awesome_AWS8Q.s3o",
	iconType			= "assaultmech",
	script				= "Mech.lua",
	corpse				= "IS_Awesome_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 24000,
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
				name	= "PPC",
				mainDir = "0 0 1",
				maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "PPC",
				mainDir = "0 0 1",
				maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "PPC",
				mainDir = "0 0 1",
				maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "SBL",
				mainDir = "0 0 1",
				maxAngleDif = 200,
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
		helptext		= "Armament: 3 x PPC, 1 x SBL - Armor: 15.5 tons Standard",
		heatlimit		= "28",
		torsoturnspeed	= "100",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Awesome_AWS8Q"] = IS_Awesome_AWS8Q })