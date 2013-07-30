weaponDef = {
	name                    = "Extended Range Small Beam Laser",
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
	range                   = 800,
	accuracy                = 300,
	targetMoveError			= 0.1,
	tolerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 2.5,
	size 					= 0.05,
	laserFlareSize			= 0.1,
	thickness				= 1,
	coreThickness			= 0.25,
	beamDecay          		= 1,
	beamTime           		= 0.5,
	beamTTL           		= 0.5,
	burst					= 10,
	burstrate				= 0.01,
	minIntensity			= 1,
	rgbcolor				= "1.0 0.4 0.4",
	intensity				= 0.75,
	damage = {
		default = 12.5, --30 DPS, 125 damage per reload
	},
	customparams = {
		heatgenerated		= "5",--2/sec
		cegflare			= "LASER_MUZZLEFLASH",
		weaponclass			= "energy",
    },
}

return lowerkeys({ ERSBL = weaponDef })