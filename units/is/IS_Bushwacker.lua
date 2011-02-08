local IS_Bushwacker = {
	name              	= "Bushwacker",
	description         = "Medium Brawler Mech",
	objectName        	= "IS_Bushwacker.s3o",
	script				= "IS_Bushwacker.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 10000,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 40 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 7000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 3.25, --64kph/10/2
		maxReverseVelocity= 1.9,
		acceleration    = 1.0,
		brakeRate       = 0.1,
		turnRate 		= 700,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "AC20",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "ERLBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "SPL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "SPL",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "MRM10",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[6] = {
				name	= "SRM6",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:SMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x LBX/20, 1 x ER Large Beam Laser, 2 x Small Pulse Laser, 1 x SRM-6, 1 x MRM-10 - Armor: 7 tons",
    },
}

return lowerkeys({ ["IS_Bushwacker"] = IS_Bushwacker })