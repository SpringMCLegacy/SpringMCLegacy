weaponDef = {
	name                    = "Laser Anti-Missile System (LAMS)",
	
	weaponType              = "BeamLaser",
	beamLaser				= true,
	explosionGenerator		= "custom:burn",
--	soundHit              	= [[GEN_Pulse_Explode1]],
	soundStart           	= [[SPL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 500,
	accuracy                = 10,
	tollerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 0.015, --0.33, 4000rpm
	size 					= 0.075,
	laserFlareSize			= 0.075,
	thickness				= 0.75,
	coreThickness			= 0.075,
	beamDecay          		= 1,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	minIntensity			= 1,
	rgbcolor				= "1.0 0.4 0.4",
	intensity				= 0.5,
	
	collisionsize = 5,
	interceptor = 1,
	coverage = 3000,
	interceptsolo = false,
	proximitypriority = 2000,
	predictboost = 50000,
	
	damage = {
		default = 10,--1 DPS
	},

}

return lowerkeys({ AMS_Dropship = weaponDef })