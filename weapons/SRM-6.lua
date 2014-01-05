weaponDef = {
	name                    = "SRM-6",
	weaponType              = "MissileLauncher",
	renderType				= 1,
	explosionGenerator    	= "custom:HE_MEDIUM",
	cegTag					= "SRMTrail",
	smokeTrail				= false,
	smokeDelay				= "0.05",
	soundHit              	= [[SRM_Hit]],
	soundStart            	= [[SRM_Fire]],
--	soundTrigger			= 0,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 600,
	accuracy                = 1000,
	sprayangle				= 2000,
	wobble					= 900,
	dance					= 65,
	guidance				= true,
	selfprop				= true,
	lineOfSight				= true,
	tracks					= true,
	turnRate				= 2000,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 5,
	burst					= 6,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 100,--10 DPS
	},
	customparams = {
		heatgenerated		= "20",--4/sec
		cegflare			= "MISSILE_MUZZLEFLASH",
		weaponclass			= "missile",
		jammable			= false,
		ammotype			= "srm",
    },
}

return lowerkeys({ SRM6 = weaponDef })