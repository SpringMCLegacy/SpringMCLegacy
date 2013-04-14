local CL_Firemoth_A = {
	name              	= "Fire Moth (Dasher) A",
	description         = "Light-class Electronic Warfare Scout",
	objectName        	= "CL_Firemoth_A.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "CL_Firemoth_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 3800,
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
	buildCostMetal      = 10000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 7.5, --150kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "TAG",
				--mainDir = "0 0 1",
				--maxAngleDif = 300,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "SRM4",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},

    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x SRM-4, 1 x TAG Laser - Armor: 2 tons Ferro-Fibrous",
		heatlimit		= "20",
		torsoturnspeed	= "200",
		rightarmid 		= "1",
		unittype		= "mech",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({ ["CL_Firemoth_A"] = CL_Firemoth_A })