weaponDef = {
	name                    = "Anti-Missile System (AMS)",
		
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
--	soundHit              	= [[MG_Hit]],
	soundStart            	= [[MG_Fire]],
	soundTrigger			= 1,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= false,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 5000,
	--accuracy                = 100,
	areaOfEffect            = 100,
	weaponVelocity          = 2400,
	reloadtime              = 0.1,
	burst					= 5,
	burstrate				= 0.01,
	--sprayAngle 				= 100,
	size					= 0.5,
	separation				= 1, 		--Distance between each plasma particle.
	stages					= 10, 		--Number of particles used in one plasma shot.
	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.9,
	
	collisionsize = 5,
	interceptor = 1,
	coverage = 1000,
	interceptsolo = false,
	proximitypriority = 2000,
	predictboost = 50000,
	damage = {
		default = 1,--1 DPS
	},
}

return lowerkeys({ AMS = weaponDef })