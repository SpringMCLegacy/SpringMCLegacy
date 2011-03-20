local CL_Maddog = {
	name              	= "Mad Dog (Vulture)",
	description         = "Heavy Missile Support Mech",
	objectName        	= "CL_Maddog.s3o",
	script				= "Mech.lua",
	corpse				= "CL_Maddog_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 16300,
	mass                = 6000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "40 50 40",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 23700,
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
				name	= "ArtemisLRM20",
				weaponSlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ArtemisLRM20",
				weaponSlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "CLPL",
				weaponSlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "CLPL",
				weaponSlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
			[5] = {
				name	= "CMPL",
				weaponSlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
			[6] = {
				name	= "CMPL",
				weaponSlaveTo = 1,
				OnlyTargetCategory = "notbeacon",
			},
			[7] = {
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
		helptext		= "Armament: 2 x LRM-20, 2 x Large Pulse Laser, 2 x Medium Pulse Laser - Armor: 8.5 tons Ferro-Fibrous",
		heatlimit		= "24",
		torsoturnspeed	= "135",
		leftarmid		= "3",
		rightarmid 		= "4",
    },
}

return lowerkeys({ ["CL_Maddog"] = CL_Maddog })