local IS_Mauler = {
	name              	= "Mauler",
	description         = "Assault-class Sniper Mech",
	objectName        	= "IS_Mauler.s3o",
	script				= "IS_Mauler.lua",
	category 			= "mech ground notbeacon",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 11500,
	mass                = 9000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "40 60 40",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 10000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 1.8, --54kph/30
		maxReverseVelocity= 0.9,
		acceleration    = .80,
		brakeRate       = 0.1,
		turnRate 		= 600,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "Gauss",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "LRM15",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "LRM15",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[5] = {
				name	= "AC2",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[6] = {
				name	= "AC2",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[7] = {
				name	= "AC2",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[8] = {
				name	= "AC2",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:XSMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Large Beam Laser, 4 x AC/2, 2 x LRM-15 - Armor: 11 tons",
    },
}

return lowerkeys({ ["IS_Mauler"] = IS_Mauler })