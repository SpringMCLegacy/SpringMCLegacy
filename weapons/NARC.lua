weaponDef = {
	name                    = "NARC Missile",
	weaponType              = "MissileLauncher",
	commandFire				= true,
	canAttackGround			= false,
	explosionGenerator    	= "custom:HE_XSMALL",
	cegTag					= "MRMTrail",
	smokeTrail				= false,
	soundHit              	= [[ATM_Hit]],
	soundStart            	= [[NARC_Fire]],
--	soundTrigger			= 0,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	canAttackGround			= false,
	range                   = 1800,
	accuracy                = 10,
	tracks					= true,
	turnRate				= 4000,
	weaponTimer				= 10,
	areaOfEffect            = 20,
	startVelocity			= 700,
	weaponVelocity          = 900,
	reloadtime              = 10,
	model					= "Missile.s3o",
	damage = {
		default 			= 0,--NONE!
	},
	customparams = {
		narc				= "1",
		cegflare			= "MISSILE_MUZZLEFLASH",
		ammotype			= "narc",
    },
}

return lowerkeys({ NARC = weaponDef })