weaponDef = {
	name                    = "Large Beam Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamBurst				= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:Laser_Large",
	--soundHit              	= [[GEN_Beam_Explode1]],
	soundStart           	= [[LBL_Fire]],
	soundTrigger			= 1,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1500,
	accuracy                = 200,
	targetMoveError			= 0.25,
	tolerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 5,
	size 					= 0.05,
	laserFlareSize			= 0.1,
	thickness				= 1.2,
	coreThickness			= 0.3,
	beamDecay          		= 1,
	beamTime           		= 0.65,
	beamTTL           		= 0.65,
	burst					= 20,
	burstrate				= 0.01,
	minIntensity			= 1,
	rgbcolor				= "1.0 0.0 1.0",
	intensity				= 0.75,
	damage = {
		default = 20, --80 DPS, 400 damage per reload
	},
	customparams = {
		heatgenerated		= "40",--8/sec
		cegflare			= "LASER_MUZZLEFLASH",
		weaponclass			= "energy",
    },
}

return lowerkeys({ LBL = weaponDef })