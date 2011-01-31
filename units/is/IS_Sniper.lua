local IS_Sniper = {
	name              	= "Sniper",
	description         = "Mobile Artillery",
	objectName        	= "IS_Sniper.s3o",
	script				= "IS_Sniper.lua",
	category 			= "tank ground",
	sightDistance       = 1000,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
	maxDamage           = 4000,
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
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 2.6, --54kph/10/2
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
			},
			[2] = {
				name	= "ERSBL",
			},
			[3] = {
				name	= "ERSBL",
				weaponslaveto3 = 2,
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:XXLARGE_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Sniper Artillery Gun, 2 x ER Small Beam Laser - Armor: 7 tons",
    },
}

return lowerkeys({ ["IS_Sniper"] = IS_Sniper })