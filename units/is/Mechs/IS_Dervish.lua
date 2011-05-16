local IS_Dervish = {
	name              	= "Dervish",
	description         = "Medium Missile Support Mech",
	objectName        	= "IS_Dervish.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Dervish_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 16100,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 50 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 21100,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.3, --86kph/30
		maxReverseVelocity= 2.15,
		acceleration    = 1.0,
		brakeRate       = 0.1,
		turnRate 		= 700,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArtemisLRM15",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ArtemisLRM15",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[6] = {
				name	= "MBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
		
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x ER LRM-15, 4 x Medium Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "22",
		torsoturnspeed	= "160",
		leftarmid		= "3",
		rightarmid 		= "5",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Dervish"] = IS_Dervish })