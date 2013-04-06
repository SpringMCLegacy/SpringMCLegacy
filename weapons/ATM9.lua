weaponDef = {
	name                    = "Advanced Tactical Missile 9",
	weaponType              = "MissileLauncher",
	renderType				= 1,
	explosionGenerator    	= "custom:HE_MEDIUM",
--	cegTag					= "RocketTrail",
	smokeTrail				= true,
	smokeDelay				= "0.05",
	soundHit              	= [[GEN_Explode2]],
	soundStart            	= [[LRM_Fire]],
--	soundTrigger			= 0,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 2600,
	accuracy                = 50,
	sprayangle				= 50,
	wobble					= 1000,
	dance 					= 100,
	guidance				= true,
	selfprop				= true,
	ballistic				= false,
	tracks					= true,
	turnRate				= 1000,
	flightTime				= 10,
	weaponTimer				= 20,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 10,
	burst					= 9,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 200,--15 DPS
	},
	customparams = {
		heatgenerated		= "60", --6/sec
		cegflare			= "MISSILE_MUZZLEFLASH",
		weaponclass			= "missile",
		ammotype			= "atm",
    },
}

return lowerkeys({ ATM9 = weaponDef })