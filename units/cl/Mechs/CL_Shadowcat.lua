local CL_Shadowcat = {
	name              	= "Shadow Cat)",
	description         = "Medium Sniper Mech",
	objectName        	= "CL_Shadowcat.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "CL_Shadowcat_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 1200,
	radarDistance      	= 2000,
		stealth				= 1,
		activateWhenBuilt   = true,
		onoffable           = true,
		radarDistanceJam    = 500,
	maxDamage           = 13400,
	mass                = 4500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 45 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 21580,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.85, --97kph/30
		maxReverseVelocity= 2.43,
		acceleration    = 1.8,
		brakeRate       = 0.1,
		turnRate 		= 950,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				mainDir = "0 0 1",
				maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CERLBL",
				mainDir = "0 0 1",
				maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "CERMBL",
				mainDir = "0 0 1",
				maxAngleDif = 200,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},

    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle, 1 x ER Large Beam Laser, 1 x ER Medium Beam Laser - Armor: 7 tons",
		heatlimit		= "20",
		torsoturnspeed	= "175",
		canjump			= "1",
		unittype		= "mech",
    },
}

return lowerkeys({ ["CL_Shadowcat"] = CL_Shadowcat })