local CL_Enyo = {
	name              	= "Enyo",
	description         = "Medium Strike Tank",
	objectName        	= "CL_Enyo.s3o",
	iconType			= "vehicle",
	script				= "Vehicle.lua",
	corpse				= "CL_Enyo_X",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 13400,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 25 44",
	collisionVolumeOffsets = "0 1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 5.5,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 15120,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 3.23, --97kph/30
		maxReverseVelocity= 1.6,
		acceleration    = 0.9,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CLPL",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "SSRM6",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "SSRM6",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Large Pulse Laser, 2 x SSRM-6 - Armor: 7 tons",
		heatlimit		= "28",
		unittype		= "vehicle",
		turretturnspeed = "100",
		elevationspeed  = "150",
    },
}

return lowerkeys({ ["CL_Enyo"] = CL_Enyo })