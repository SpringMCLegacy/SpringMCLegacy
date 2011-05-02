local CL_Ares = {
	name              	= "Ares",
	description         = "Medium Sniper Tank",
	objectName        	= "CL_Ares.s3o",
	script				= "Vehicle.lua",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 8000,
	mass                = 4000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 28 40",
	collisionVolumeOffsets = "0 1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 4,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 40,
	buildCostMetal      = 2000,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.8, --86kph/30
		maxReverseVelocity= 1.6,
		acceleration    = 0.8,
		brakeRate       = 0.1,
		turnRate 		= 450,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CERLBL",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ATM9",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "ATM9",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x ER Large Beam Laser, 2 x ATM-9 - Armor: 4.5 tons",
		heatlimit		= "26",
		unittype		= "vehicle",
		turretturnspeed = "75",
		elevationspeed  = "100",
    },
}

return lowerkeys({ ["CL_Ares"] = CL_Ares })