local CL_Mars = {
	name              	= "Mars",
	description         = "Heavy Strike Tank",
	objectName        	= "CL_Mars.s3o",
	script				= "Vehicle.lua",
	corpse				= "CL_Mars_X",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	noChaseCategory		= "beacon air",
	stealth				= 1,
	sightDistance       = 800,
	radarDistance      	= 1500,
		stealth				= 1,
		activateWhenBuilt   = true,
		onoffable           = true,
		radarDistanceJam    = 500,
	maxDamage           = 26800,
	mass                = 10000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "38 27 52",
	collisionVolumeOffsets = "0 -1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 10,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Mars",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 100,
	buildCostMetal      = 31500,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.06, --32kph/30
		maxReverseVelocity= 1.5,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 400,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CERLBL",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "LBX10",
				mainDir = "0 0 1",
				maxAngleDif = 35,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[5] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 4,
			},
			[6] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 4,
			},
			[7] = {
				name	= "MG",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[8] = {
				name	= "MG",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle, 1 x ER Large Beam Laser, 1 x LBX/10, 3 x LRM-15 - Armor: 15 tons",
		heatlimit		= "36",
		unittype		= "vehicle",
		wheelspeed      = "50",
		turretturnspeed = "50",
		elevationspeed  = "100",
		barrelrecoildist = "{[1] = 5, [3] = 5}",
		barrelrecoilspeed = "100",
		turrets = "{[3] = 3}",
    },
}

return lowerkeys({ ["CL_Mars"] = CL_Mars })