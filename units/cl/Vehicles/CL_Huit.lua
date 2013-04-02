local CL_Huit = {
	name              	= "Huitzilopochtli",
	description         = "Heavy Artillery Support Vehicle",
	objectName        	= "CL_Huit.s3o",
	iconType			= "vehicle",
	script				= "Vehicle.lua",
	corpse				= "CL_Huit_X",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		stealth				= 1,
		activateWhenBuilt   = true,
		onoffable           = true,
		radarDistanceJam    = 500,
	maxDamage           = 9800,
	mass                = 8500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "24 18 38",
	collisionVolumeOffsets = "0 1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 8.5,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 22,--width to render the decal
	buildCostEnergy     = 85,
	buildCostMetal      = 12420,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.06, --32kph/30
		maxReverseVelocity= 0.8,
		acceleration    = 0.9,
		brakeRate       = 0.1,
		turnRate 		= 500,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArrowIV",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ArrowIV",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "CMPL",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "CMPL",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Arrow IV Artillery Missle, 2 x Medium Pulse Laser - Armor: 5.5 tons",
		heatlimit		= "20",
		unittype		= "vehicle",
		turretturnspeed = "50",
		elevationspeed  = "75",
    },
}

return lowerkeys({ ["CL_Huit"] = CL_Huit })