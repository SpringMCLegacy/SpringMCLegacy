weaponDef = {
	name                    = "Clan Extended Range Large Beam Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamLaser				= 1,
--	beamWeapon				= true,
--	largeBeamLaser			= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:AP_SMALL",
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
	beamTime           		= 1,
	beamTTL           		= 1,
	minIntensity			= 1,
	rgbcolor				= "0.5 0.0 1.0",
	intensity				= 0.75,
	damage = {
		default = 500, --100 DPS
		beacons = 0,
		light = 500,
		medium = 425,
		heavy = 350,
		assault = 250,
		vehicle = 750,
	},
	customparams = {
		heatgenerated		= "60",--12/sec
    },
}

return lowerkeys({ CERLBL = weaponDef })