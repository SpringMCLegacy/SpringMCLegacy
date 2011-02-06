weaponDef = {
	name                    = "Medium Range Missile 10",
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
	wobble					= 1300,
	dance					= 100,
	guidance				= true,
	selfprop				= true,
	ballistic				= true,
	trajectoryHeight		= 0.1,
	tracks					= false,
	turnRate				= 5000,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 500,
	weaponVelocity          = 700,
	reloadtime              = 5,
	burst					= 10,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	damage = {
		default = 50,--10 DPS
	},
	customparams = {
		heatgenerated		= "20",--4/sec
    },
}

return lowerkeys({ MRM10 = weaponDef })