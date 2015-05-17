weaponDef = {
	name                    = "Microlaer",
	weaponType              = "BeamLaser",
	beamLaser				= true,
	beamBurst				= true,
	renderType				= 0,
	lineOfSight				= true,
	explosionGenerator		= "custom:burn",
	--soundHit              	= [[GEN_Beam_Explode1]],
	soundStart           	= [[SBL_Fire]],
	soundTrigger			= 1,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 200,
	accuracy                = 200,
	targetMoveError			= 0.1,
	tolerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	reloadtime              = 0.01,
	size 					= 0.05,
	laserFlareSize			= 0.1,
	thickness				= 1,
	coreThickness			= 0.25,
	beamDecay          		= 1,
	beamTime           		= 0.01,
	beamTTL           		= 0.01,
	burst					= 1,
	burstrate				= 0.01,
	minIntensity			= 1,
	rgbcolor				= "1.0 1.0 0.1",
	intensity				= 0.75,
	damage = {
		default = 1, --30 DPS, 125 damage per reload
	},
	customparams = {
		heatgenerated		= "1",--1/sec
		cegflare			= "SMALLLASER_MUZZLEFLASH",
		weaponclass			= "energy",
		flareonshot 		= true,
    },
}

return lowerkeys({ Microlaser = weaponDef })