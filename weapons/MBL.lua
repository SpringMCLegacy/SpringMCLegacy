weaponDef = {
	name                    = "Medium Beam Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamBurst				= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator		= "custom:burn",
	--soundHit              	= [[GEN_Beam_Explode1]],
	soundStart           	= [[MBL_Fire]],
	soundTrigger			= 1,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 900,
	accuracy                = 300,
	targetMoveError			= 0.1,
	tolerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 3,
	size 					= 0.05,
	laserFlareSize			= 0.1,
	thickness				= 1.5,
	coreThickness			= 0.4,
	beamDecay          		= 1,
	beamTime           		= 0.5,
	beamTTL           		= 0.5,
	burst					= 15,
	burstrate				= 0.01,
	minIntensity			= 1,
	rgbcolor				= "0.4 1.0 0.4",
	intensity				= 0.75,
	damage = {
		default = 10,--10 DPS, 150 damage per reload
	},
	customparams = {
		heatgenerated		= "9",--3/sec
		cegflare			= "MEDIUMLASER_MUZZLEFLASH",
		weaponclass			= "energy",
		flareonshot 		= true,
    },
}

return lowerkeys({ MBL = weaponDef })