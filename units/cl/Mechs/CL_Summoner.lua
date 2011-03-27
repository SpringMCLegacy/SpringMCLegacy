local CL_Summoner = {
	name              	= "Summoner (Thor)",
	description         = "Heavy Brawler Mech",
	objectName        	= "CL_Summoner.s3o",
	iconType			= "heavymech",
	script				= "Mech.lua",
	corpse				= "CL_Summoner_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 18200,
	mass                = 7000,
	footprintX			= 3,
	footprintZ 			= 3,
	--collisionVolumeType = "box",
	--collisionVolumeScales = "40 50 40",
	--collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	usePieceCollisionVolumes = true,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 70,
	buildCostMetal      = 34580,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 4.3, --86kph/20
		maxReverseVelocity= 2.15,
		acceleration    = 1,
		brakeRate       = 0.2,
		turnRate 		= 700,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "UAC20",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "CLPL",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "CSPL",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "SRM6",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x UAC/20, 1 x Large Pulse Laser, 1 x Small Pulse Laser, 1 x SRM-6 - Armor: 9.5 tons Ferro-Fibrous",
		heatlimit		= "28",
		torsoturnspeed	= "130",
		canjump			= "1",
    },
}

return lowerkeys({ ["CL_Summoner"] = CL_Summoner })