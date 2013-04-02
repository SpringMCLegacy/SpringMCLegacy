local IS_Hollander = {
	name              	= "Hollander",
	description         = "BZK-F3",
	objectName        	= "IS_Hollander.s3o",
	iconType			= "mediummech",
	script				= "Mech.lua",
	corpse				= "IS_Hollander_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 9800,
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
	buildCostMetal      = 14900,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "SMALLMECH",
		maxVelocity		= 4.3, --86kph/20
		maxReverseVelocity= 2.15,
		acceleration    = 1.5,
		brakeRate       = 0.1,
		turnRate 		= 900,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				mainDir = "0 0 1",
				maxAngleDif = 270,
				OnlyTargetCategory = "notbeacon",
			},
--			[2] = {
--				name	= "SBL",
--				--mainDir = "0 0 1",
--				--maxAngleDif = 270,
--				OnlyTargetCategory = "notbeacon",
--				SlaveTo = 1,
--			},
--			[3] = {
--				name	= "SBL",
--				--mainDir = "0 0 1",
--				--maxAngleDif = 270,
--				OnlyTargetCategory = "notbeacon",
--				SlaveTo = 1,
--			},
--			[4] = {
--				name	= "SPL",
--				--mainDir = "0 0 1",
--				--maxAngleDif = 270,
--				OnlyTargetCategory = "notbeacon",
--				SlaveTo = 1,
--			},
--			[5] = {
--				name	= "SPL",
--				--mainDir = "0 0 1",
--				--maxAngleDif = 270,
--				OnlyTargetCategory = "notbeacon",
--				SlaveTo = 1,
--			},
		},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle: 5.5 tons Standard",
		heatlimit		= "14",
		torsoturnspeed	= "140",
		leftarmid 		= "2",
		rightarmid 		= "3",
		unittype		= "mech",
    },
}

return lowerkeys({ ["IS_Hollander"] = IS_Hollander })