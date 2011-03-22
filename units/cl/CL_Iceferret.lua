local CL_Iceferret = {
	name              	= "Ice Ferret (Fenris)",
	description         = "Medium Brawler Mech",
	objectName        	= "CL_Iceferret.s3o",
	script				= "Mech.lua",
	corpse				= "CL_Iceferret_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	sightDistance       = 1200,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 11400,
	mass                = 4500,
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
	buildCostEnergy     = 45,
	buildCostMetal      = 17400,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 6.5, --130kph/30
		maxReverseVelocity= 3.25,
		acceleration    = 1.8,
		brakeRate       = 0.1,
		turnRate 		= 850,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "CMPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "SRM6",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[6] = {
				name	= "AMS",
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
		helptext		= "Armament: 4 x Medium Pulse Laser, 1 x SRM-6 - Armor: 7.5 tons Ferro-Fibrous",
		heatlimit		= "24",
		torsoturnspeed	= "190",
    },
}

return lowerkeys({ ["CL_Iceferret"] = CL_Iceferret })