local IS_Sniper = {
	name              	= "Sniper",
	description         = "Mobile Artillery",
	objectName        	= "IS_Sniper.s3o",
	script				= "IS_Sniper.lua",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	sightDistance       = 1000,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 2000,
	mass                = 8000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 20 40",
	collisionVolumeOffsets = "0 3 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 8,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 5000,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.8, --54kph/30
		maxReverseVelocity= 1.3,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 300,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Sniper",
				mainDir = "0 0 1",
				maxAngleDif = 15,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "ERSBL",
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "ERSBL",
				weaponslaveto = 2,
				OnlyTargetCategory = "notbeacon",
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:ARTILLERY_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Sniper Artillery Gun, 2 x ER Small Beam Laser - Armor: 7 tons",
    },
}

return lowerkeys({ ["IS_Sniper"] = IS_Sniper })