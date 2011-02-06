weaponDef = {
	name                    = "Large Pulse Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamLaser				= 1,
--	beamWeapon				= true,
--	largeBeamLaser			= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:AP_MEDIUM",
	soundHit              	= [[GEN_Pulse_Explode1]],
	soundStart           	= [[LPL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1000,
	accuracy                = 250,
	tollerance				= 100,
	areaOfEffect            = 10,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 0.75,
	size 					= 0.1,
	laserFlareSize			= 0.1,
	thickness				= 1,
	coreThickness			= 0.1,
	beamDecay          		= 1,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	minIntensity			= 1,
	rgbcolor				= "0.4 0.0 0.8",
	intensity				= 0.75,
	damage = {
		default = 67.5, --90 DPS
	},
	
	
	
}

return lowerkeys({ LPL = weaponDef })