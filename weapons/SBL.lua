weaponDef = {
	name                    = "Small Beam Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamBurst				= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:Laser_Small",
	--soundHit              	= [[GEN_Beam_Explode1]],
	soundStart           	= [[SBL_Fire]],
	soundTrigger			= 1,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 300,
	accuracy                = 10,
	tolerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 2.5,
	size 					= 0.05,
	laserFlareSize			= 0.1,
	thickness				= 0.75,
	coreThickness			= 0.1,
	beamDecay          		= 1,
	beamTime           		= 0.35,
	beamTTL           		= 0.35,
	burst					= 10,
	burstrate				= 0.01,
	minIntensity			= 1,
	rgbcolor				= "1.0 0.4 0.4",
	intensity				= 0.75,
	damage = {
		default = 12.5, --30 DPS, 125 damage per reload
	},
	customparams = {
		heatgenerated		= "2.5",--1/sec
		cegflare			= "LASER_MUZZLEFLASH",
    },
}

return lowerkeys({ SBL = weaponDef })