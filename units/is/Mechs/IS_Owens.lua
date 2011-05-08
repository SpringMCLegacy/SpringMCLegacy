local IS_Owens = {
	name              	= "Owens",
	description         = "Light Missile Support Mech",
	objectName        	= "IS_Owens.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "IS_Owens_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 1200,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 11200,
	mass                = 3500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 35 15",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 35,
	buildCostMetal      = 15180,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 6.5, --130kph/30
		maxReverseVelocity= 3.25,
		acceleration    = 1.75,
		brakeRate       = 0.1,
		turnRate 		= 900,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ArtemisLRM5",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ArtemisLRM5",
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
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "ERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Artemis-enhanced LRM-5, 2 x ER Small Beam Laser, 1 x Medium Beam Laser - Armor: 7 tons",
		heatlimit 		= "16",
		torsoturnspeed	= "185",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Owens"] = IS_Owens })