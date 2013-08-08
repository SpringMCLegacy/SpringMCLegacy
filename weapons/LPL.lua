weaponDef = {
	name                    = "Large Pulse Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamBurst				= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator		= "custom:burn",
--	soundHit              	= [[GEN_Pulse_Explode1]],
	soundStart           	= [[LPL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1000,
	accuracy                = 50,
	tollerance				= 100,
	areaOfEffect            = 10,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 3.75,
	size 					= 0.1,
	laserFlareSize			= 0.1,
	thickness				= 2,
	coreThickness			= 0.5,
	beamDecay          		= 1,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	burst					= 5,
	burstrate				= 0.1,
	minIntensity			= 1,
	rgbcolor				= "0.4 0.0 0.8",
	intensity				= 1,
	damage = {
		default = 13.5, --90 DPS, 67.5 damage per reload
	},
	customparams = {
		heatgenerated		= "7.5",--10/sec
		cegflare			= "LASER_MUZZLEFLASH",
		weaponclass			= "energy",
    },
}

return lowerkeys({ LPL = weaponDef })