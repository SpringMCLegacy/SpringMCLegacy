local CL_Kitfox = {
	name              	= "Kit Fox (Uller)",
	description         = "Light Scout Mech",
	objectName        	= "CL_Kitfox.s3o",
	script				= "CL_Kitfox.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 4000,
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
	buildCostEnergy     = 0,
	buildCostMetal      = 2000,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.85, --97kph/10/2
		maxReverseVelocity= 2.5,
		acceleration    = 1.8,
		brakeRate       = 0.1,
		turnRate 		= 950,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CERLBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
			},
			[2] = {
				name	= "AC5",
				--weaponSlaveTo2 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
			},
			[3] = {
				name	= "CSPL",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
			},
			[4] = {
				name	= "SSRM4",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	sfxtypes = {
		explosiongenerators = {
		"custom:SMALL_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x AC/5, 1 x Small Pulse Laser, 1 x SSRM-4 - Armor: 4 tons",
    },
}

return lowerkeys({ ["CL_Kitfox"] = CL_Kitfox })