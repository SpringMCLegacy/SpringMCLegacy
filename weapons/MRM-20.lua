weaponDef = {
	name                    = "Medium Range Missile 20",
	weaponType              = "MissileLauncher",
	renderType				= 1,
	explosionGenerator    	= "custom:HE_MEDIUM",
--	cegTag					= "BazookaTrail",
	smokeTrail				= true,
	smokeDelay				= "0.05",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[MRM_Fire]],
--	soundTrigger			= 0,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1500,
	accuracy                = 1000,
	sprayAngle				= 500,
	ballistic				= true,
	trajectoryHeight		= 0.1,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 750,
	weaponVelocity          = 1000,
	reloadtime              = 10,
	burst					= 20,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 100,--10 DPS
	},
	customparams = {
		heatgenerated		= "60",--4/sec
		cegflare			= "MISSILE_MUZZLEFLASH",
		weaponclass			= "missile",
		ammotype			= "mrm",
    },
}

return lowerkeys({ MRM20 = weaponDef })