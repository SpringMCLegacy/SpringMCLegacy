weaponDef = {
	name                    = "Laser AMS",
	
	weaponType              = "BeamLaser",
	explosionGenerator		= "custom:burn",
--	soundHit              	= [[GEN_Pulse_Explode1]],
	soundStart           	= [[SPL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1500,
	accuracy                = 5,
	tolerance				= 50000,
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
	airSightDistance 		= 1500,
	
	collisionsize = 5,
	interceptor = 1,
	coverage = 1500,
	interceptsolo = false,
	proximitypriority = -1,
	predictboost = 500,
	
	--beamBurst				= true,
	--burst 					= 5,
	--burstRate				= 0.015,
	cylinderTargeting		= 5,
	
	damage = {
		default = 1000,--1 DPS
	},
	customparams = {
		cegflare			= "SMALLLASER_MUZZLEFLASH",
		flareonshot			= true,
		turretturnspeed		= 3000,
		elevationspeed		= 5000,
	},

}

return lowerkeys({ LAMS = weaponDef })