local CL_Mistlynx = {
	name              	= "Mist Lynx (Koshi)",
	description         = "Light Missile Support Mech",
	objectName        	= "CL_Mistlynx.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "CL_Mistlynx_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	sightDistance       = 1200,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 6700,
	mass                = 2000,
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
	buildCostEnergy     = 20,
	buildCostMetal      = 13650,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 6.5, --130kph/30
		maxReverseVelocity= 3.25,
		acceleration    = 2.0,
		brakeRate       = 0.1,
		turnRate 		= 900,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "LRM10",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "NARC",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "MG",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "MG",
				--weaponSlaveTo3 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[5] = {
				name	= "SSRM4",
				--weaponSlaveTo2 = 1,
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:MG_MUZZLEFLASH",
		"custom:JumpJetTrail",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x LRM-10, 1 x SSRM-4, 2 x MG - Armor: 3.5 tons Ferro-Fibrous",
		heatlimit		= "20",
		torsoturnspeed	= "200",
		canjump			= "1",
    },
}

return lowerkeys({ ["CL_Mistlynx"] = CL_Mistlynx })