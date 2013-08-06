local IS_Hollander_BZKF3 = {
	name              	= "Hollander BZK-F3",
	description         = "Light-class Long Range Fire Support/Sniper",
	objectName        	= "IS_Hollander_BZKF3.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Hollander_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 7100,
	mass                = 4500,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "35 50 20",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal        = 0,--      = 14900,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4, --80kph/20
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				--mainDir = "0 0 1",
				--maxAngleDif = 270,
				OnlyTargetCategory = "ground",
			},
		},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle - Armor: 4 tons Ferro-Fibrous",
		heatlimit		= "10",
		torsoturnspeed	= "140",
		unittype		= "mech",
		maxammo 		= {gauss = 20},
		
    },
}

return lowerkeys({ ["IS_Hollander_BZKF3"] = IS_Hollander_BZKF3 })