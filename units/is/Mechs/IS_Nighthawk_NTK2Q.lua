local IS_Nighthawk_NTK2Q = {
	name              	= "Night Hawk NTK-2Q",
	description         = "Light Sniper Mech",
	objectName        	= "IS_Nighthawk_NTK2Q.s3o",
	iconType			= "lightmech",
	script				= "Mech.lua",
	corpse				= "IS_Nighthawk_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
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
	buildCostMetal      = 15000,
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
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "LBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "MPL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
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
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x Large Beam Laser, 1 x Medium Pulse Laser - Armor: 7.5 tons Stabdard",
		heatlimit 		= "22",
		torsoturnspeed	= "180",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Nighthawk_NTK2Q"] = IS_Nighthawk_NTK2Q })