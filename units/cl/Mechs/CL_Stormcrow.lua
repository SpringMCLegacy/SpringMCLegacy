local CL_Stormcrow = {
	name              	= "Stormcrow (Ryoken)",
	description         = "Medium Missile Support Mech",
	objectName        	= "CL_Stormcrow.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "CL_Stormcrow_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 18200,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 50 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 27040,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.85, --97kph/30
		maxReverseVelocity= 2.43,
		acceleration    = 1.5,
		brakeRate       = 0.1,
		turnRate 		= 800,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArtemisLRM20",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[5] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[6] = {
				name	= "SRM4",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[7] = {
				name	= "SRM4",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},

    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x LRM-20, 4 x Medium Pulse Laser, 2 x SRM-4 - Armor: 9.5 tons",
		heatlimit		= "20",
		torsoturnspeed	= "160",
		unittype		= "mech",
    },
}

return lowerkeys({ ["CL_Stormcrow"] = CL_Stormcrow })