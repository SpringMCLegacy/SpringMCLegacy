local IS_LRMCarrier = {
	name              	= "LRM Carrier",
	description         = "Missile Support Vehicle",
	objectName        	= "IS_LRMCarrier.s3o",
	iconType			= "vehicle",
	script				= "Vehicle.lua",
	corpse				= "IS_LRMCarrier_X",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 8000,
	mass                = 6000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 25 38",
	collisionVolumeOffsets = "0 2 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 6,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 60,
	buildCostMetal      = 10800,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.8, --54kph/30
		maxReverseVelocity= 0.9,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 300,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LRM20",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "LRM20",
				SlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x LRM-20 - Armor: 2 tons",
		heatlimit		= "26",
		unittype		= "vehicle",
		turretturnspeed = "25",
		elevationspeed  = "50",
		wheelspeed      = "200",
    },
}

return lowerkeys({ ["IS_LRMCarrier"] = IS_LRMCarrier })