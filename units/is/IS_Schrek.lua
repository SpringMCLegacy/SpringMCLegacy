local IS_Schrek = {
	name              	= "Schrek",
	description         = "Medium Sniper Tank",
	objectName        	= "IS_Schrek.s3o",
	script				= "IS_Schrek.lua",
	explodeAs          	= "mechexplode",
	category 			= "tank ground notbeacon",
	sightDistance       = 800,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
		onoffable           = true,
	maxDamage           = 3500,
	mass                = 8000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "27 20 46",
	collisionVolumeOffsets = "0 -1 0",
	collisionVolumeTest = 1,
	leaveTracks			= 1,
	trackOffset			= 10,--no idea what this does
	trackStrength		= 8,--how visible the tracks are
	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
	trackType			= "Thin",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 0,
	buildCostMetal      = 4250,
	buildTime           = 0,
	canMove				= true,
		movementClass   = "TANK",
		maxVelocity		= 1.8, --54kph/30
		maxReverseVelocity= 1.6,
		acceleration    = 0.6,
		brakeRate       = 0.1,
		turnRate 		= 300,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "PPC",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "PPC",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "PPC",
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:PPC_MUZZLEFLASH",
		},
	},
	customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 3 x Particle Projector Cannon - Armor: 7 tons",
    },
}

return lowerkeys({ ["IS_Schrek"] = IS_Schrek })