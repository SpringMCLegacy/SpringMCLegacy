weaponDef = {
	name                    = "Clan Large Pulse Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamLaser				= 1,
--	beamWeapon				= true,
--	largeBeamLaser			= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:Laser_Large",
	soundHit              	= [[GEN_Pulse_Explode1]],
	soundStart           	= [[LPL_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1200,
	accuracy                = 50,
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
	intensity				= 1,
	damage = {
		default = 75, --100 DPS
		beacons = 0,
		light = 75,
		medium = 67.5, --90%
		heavy = 60, --80%
		assault = 52.5, --70%
		vehicle = 112.5, --150%
	},
	customparams = {
		heatgenerated		= "7.5",--10/s
		cegflare			= "LASER_MUZZLEFLASH",
    },
	
	
}

return lowerkeys({ CLPL = weaponDef })