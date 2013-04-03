weaponDef = {
	name                    = "Clan Small Pulse Laser",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamBurst				= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator    	= "custom:Laser_Small",
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
	reloadtime              = 1.65,
	size 					= 0.075,
	laserFlareSize			= 0.075,
	thickness				= 0.75,
	coreThickness			= 0.075,
	beamDecay          		= 1,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	burst					= 5,
	burstrate				= 0.1,
	minIntensity			= 1,
	rgbcolor				= "1.0 0.4 0.4",
	intensity				= 0.5,
	damage = {
		default = 1.8, --30 DPS, 9 damage per reload
	},
	customparams = {
		heatgenerated		= "0.66",--2/sec
		cegflare			= "LASER_MUZZLEFLASH",
    },
}

return lowerkeys({ CSPL = weaponDef })