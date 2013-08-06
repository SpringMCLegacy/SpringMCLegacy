local IS_Chimera_CMA1S = {
	name              	= "Chimera CMA-1S",
	description         = "Medium-class Mid Range Skirmisher",
	objectName        	= "IS_Chimera_CMA1S.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Chimera_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 11200,
	mass                = 4000,
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
	buildCostEnergy     = 40,
	buildCostMetal        = 0,--      = 17270,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.5, --90kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "ERLBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERMBL",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "MG",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "MRM20",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "ground",
				SlaveTo = 1,
			},
		},
		
	--Gets CEG effects from /gamedata/explosions folder

	--[[sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		"custom:JumpJetTrail",
		},
	},]]
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x Medium Pulse Laser, 1 x Machinegun, 2 x MRM-10 - Armor: 7 tons Standard",
		heatlimit		= "20",
		torsoturnspeed	= "170",
		canjump			= "1",
		unittype		= "mech",
		maxammo 		= {mrm = 400},
    },
}

return lowerkeys({ ["IS_Chimera_CMA1S"] = IS_Chimera_CMA1S })