local IS_Orion = {
	name              	= "Orion",
	description         = "Heavy Brawler Mech",
	objectName        	= "IS_Orion.s3o",
	iconType			= "heavymech",
	script				= "Mech.lua",
	corpse				= "IS_Orion_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 22400,
	mass                = 7500,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "45 50 40",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 75,
	buildCostMetal      = 28600,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 3.25, --65kph/3
		maxReverseVelocity= 1.63,
		acceleration    = 1,
		brakeRate       = 0.2,
		turnRate 		= 650,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LPL",
				mainDir = "0 0 1",
				maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "MPL",
				mainDir = "0 0 1",
				maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "AC20",
				mainDir = "0 0 1",
				maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "SRM6",
				mainDir = "0 0 1",
				maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "SRM6",
				mainDir = "0 0 1",
				maxAngleDif = 240,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:PPC_MUZZLEFLASH",
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x AC/20, 1 x Large Pulse Laser, 1 x Medium Pulse Laser, 2 x SRM-6 - Armor: 12.5 tons Standard",
		heatlimit		= "29",
		torsoturnspeed	= "120",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Orion"] = IS_Orion })