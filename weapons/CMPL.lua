weaponDef = {
	name                    = "Clan Medium Pulse Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamLaser				= 1,
--	beamWeapon				= true,
--	largeBeamLaser			= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:AP_SMALL",
	soundHit              	= [[GEN_Pulse_Explode1]],
	soundStart           	= [[MPL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1200,
	accuracy                = 250,
	tollerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 0.6,
	size 					= 0.1,
	laserFlareSize			= 0.1,
	thickness				= 1,
	coreThickness			= 0.1,
	beamDecay          		= 1,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	minIntensity			= 1,
	rgbcolor				= "0.4 0.8 0.4",
	intensity				= 0.6,
	damage = {
		default = 42, --70 DPS
	},
	
	
	
}

return lowerkeys({ CMPL = weaponDef })