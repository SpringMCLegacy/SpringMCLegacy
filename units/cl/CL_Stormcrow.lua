local CL_Stormcrow = {
	name              	= "Stormcrow (Ryoken)",
	description         = "Medium Combat Mech",
	objectName        	= "CL_Stormcrow.s3o",
	script				= "CL_Stormcrow.lua",
	category 			= "mech ground",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 8000,
	mass                = 5500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "30 50 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 6500,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 4.85, --97kph/10/2
		maxReverseVelocity= 3.0,
		acceleration    = 1.5,
		brakeRate       = 0.1,
		turnRate 		= 800,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CLPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[2] = {
				name	= "CERMBL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[3] = {
				name	= "CLPL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[4] = {
				name	= "CERMBL",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[5] = {
				name	= "CERMBL",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
			},
			[6] = {
				name	= "LRM20",
				--weaponSlaveTo4 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
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
		helptext		= "Armament: 2 x Large Pulse Laser, 3 x ER Medium Beam Laser, 1 x LRM-20 - Armor: 7 tons",
    },
}

return lowerkeys({ ["CL_Stormcrow"] = CL_Stormcrow })