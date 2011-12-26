weaponDef = {
	name                    = "Clan Extended Range Large Beam Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamLaser				= 1,
--	beamWeapon				= true,
--	largeBeamLaser			= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:Laser_Large",
	soundHit              	= [[GEN_Beam_Explode1]],
	soundStart           	= [[LBL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 2000,
	accuracy                = 50,
	tollerance				= 100,
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
	minIntensity			= 1,
	rgbcolor				= "0.5 0.0 1.0",
	intensity				= 1,
	damage = {
		default = 500, --200 DPS
	},
	customparams = {
		heatgenerated		= "60",--12/sec
		cegflare			= "LASER_MUZZLEFLASH",
    },
}

return lowerkeys({ CERLBL = weaponDef })