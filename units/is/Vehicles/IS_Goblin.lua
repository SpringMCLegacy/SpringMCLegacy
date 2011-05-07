local IS_Goblin = {
	name              	= "Goblin",
	description         = "Medium Brawler Tank",
	objectName        	= "IS_Goblin.s3o",
	script				= "Vehicle.lua",
	corpse				= "IS_Goblin_X",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 9600,
	mass                = 4500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 18 36",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 4.5,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 10710,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.16, --65kph/30
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LPL",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[2] = {
				name	= "SRM6",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "MG",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "MG",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "AMS",
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Large Pulse Laser, 1 x SRM-6, 2 x Machinegun, Laser Anti-Missile System - Armor: 8 tons",
		heatlimit		= "20",
		unittype		= "vehicle",
		turrettunspeed  = "75",
		elevationspeed  = "200",
		wheelspeed      = "200",
    },
}

return lowerkeys({ ["IS_Goblin"] = IS_Goblin })