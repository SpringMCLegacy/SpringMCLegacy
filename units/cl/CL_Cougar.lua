local CL_Cougar = {
	name              	= "Cougar",
	description         = "Light Brawler Mech",
	objectName        	= "CL_Cougar.s3o",
	script				= "CL_Cougar.lua",
	category 			= "mech ground notbeacon",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 5500,
	mass                = 3500,
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
	buildCostEnergy     = 0,
	buildCostMetal      = 3000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 2.86, --86kph/30
		maxReverseVelocity= 1.43,
		acceleration    = 1.7,
		brakeRate       = 0.1,
		turnRate 		= 950,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CLPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CLPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "SSRM4",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "SSRM4",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:MEDIUM_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 2 x Large Pulse Laser, 2 x SSRM-4 - Armor: 5.5 tons",
    },
}

return lowerkeys({ ["CL_Cougar"] = CL_Cougar })