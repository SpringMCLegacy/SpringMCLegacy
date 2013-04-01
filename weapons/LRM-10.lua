weaponDef = {
	name                    = "Long Range Missile 10",
	weaponType              = "MissileLauncher",
	renderType				= 1,
	explosionGenerator    	= "custom:HE_MEDIUM",
--	cegTag					= "RocketTrail",
	smokeTrail				= true,
	smokeDelay				= "0.05",
	soundHit              	= [[GEN_Explode2]],
	soundStart            	= [[LRM_Fire]],
--	soundTrigger			= 0,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 2100,
	accuracy                = 1000,
	sprayangle				= 1000,
	wobble					= 1750,
	dance 					= 100,
	guidance				= true,
	selfprop				= true,
	ballistic				= false,
	trajectoryHeight		= 1,
	tracks					= true,
	turnRate				= 1000,
	flightTime				= 10,
	weaponTimer				= 20,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 15,
	burst					= 10,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 150,--10 DPS
	},
	customparams = {
		heatgenerated		= "60", --5/sec
		cegflare			= "MISSILE_MUZZLEFLASH",
    },
}

return lowerkeys({ LRM10 = weaponDef })