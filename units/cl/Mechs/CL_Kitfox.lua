local CL_Kitfox = {
	name              	= "Kit Fox (Uller)",
	description         = "Light Strike Mech",
	objectName        	= "CL_Kitfox.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "CL_Kitfox_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 7600,
	mass                = 3000,
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
	buildCostEnergy     = 30,
	buildCostMetal      = 13320,
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
				name	= "CERLBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[2] = {
				name	= "UAC5",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "CSPL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "SRM4",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x UAC/5, 1 x Small Pulse Laser, 1 x SRM-6 - Armor: 4 tons Ferro-Fibrous",
		heatlimit		= "20",
		torsoturnspeed	= "180",
		unittype		= "mech",
    },
}

return lowerkeys({ ["CL_Kitfox"] = CL_Kitfox })