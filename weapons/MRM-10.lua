weaponDef = {
	name                    = "MRM-10",
	weaponType              = "MissileLauncher",
	renderType				= 1,
	explosionGenerator    	= "custom:HE_SMALL",
	cegTag					= "MRMTrail",
	smokeTrail				= false,
	smokeDelay				= "0.05",
	soundHit              	= [[MRM_Hit]],
	soundStart            	= [[MRM_Fire]],
--	soundTrigger			= 0,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1500,
	accuracy                = 100,
	sprayAngle				= 400,
	ballistic				= true,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 900,
	weaponVelocity          = 900,
	reloadtime              = 10,
	burst					= 10,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 100,--10 DPS
	},
	customparams = {
		heatgenerated		= "40",--4/sec
		cegflare			= "MISSILE_MUZZLEFLASH",
		weaponclass			= "missile",
		jammable			= false,
		ammotype			= "mrm",
    },
}

return lowerkeys({ MRM10 = weaponDef })