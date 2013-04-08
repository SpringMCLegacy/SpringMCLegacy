weaponDef = {
	name                    = "NARC Missile",
	weaponType              = "MissileLauncher",
	renderType				= 1,
	commandFire				= true,
	canAttackGround			= false,
	explosionGenerator    	= "custom:HE_XSMALL",
--	cegTag					= "BazookaTrail",
	smokeTrail				= true,
	smokeDelay				= "0.05",
	soundHit              	= [[GEN_Explode3]],
	soundStart            	= [[NARC_Fire]],
--	soundTrigger			= 0,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1800,
	accuracy                = 10,
	guidance				= true,
	selfprop				= true,
	lineOfSight				= true,
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