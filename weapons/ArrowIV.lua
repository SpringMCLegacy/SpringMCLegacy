weaponDef = {
	name                    = "Arrow Missile",
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_XLARGE",
	cegTag					= "ArrowIVTrail",
	smokeTrail				= false,
	soundHit              	= [[Arrow_Hit]],
	soundStart            	= [[Arrow_Fire]],
--	soundTrigger			= 0,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 4000,
	accuracy                = 1000,
	wobble					= 200,
	trajectoryHeight		= 1,
	tracks					= false,
	turnRate				= 500,
	weaponTimer				= 50,
	flightTime				= 50,
	areaOfEffect            = 200,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 15,
	model					= "Weapons/LargeMissile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 3000,--200 DPS
	},
	customparams = {
		heatgenerated		= 15,--10/sec
		cegflare			= "ARROW_MUZZLEFLASH",
		weaponclass			= "missile",
		ammotype			= "arrow",
		shockwave			= true,
    },
}

return lowerkeys({ ArrowIV = weaponDef })