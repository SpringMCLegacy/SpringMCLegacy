weaponDef = {
	name                    = "Machinegun",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
--	soundHit              	= [[MG_Hit]],
	soundStart            	= [[MG_Fire]],
	soundTrigger			= 1,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= false,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 800,
	accuracy                = 100,
	areaOfEffect            = 1,
	weaponVelocity          = 1200,
	reloadtime              = 0.8,
	burst					= 6,
	burstrate				= 0.08,
	sprayAngle 				= 100,
	size					= 0.5,
	separation				= 1, 		--Distance between each plasma particle.
	stages					= 10, 		--Number of particles used in one plasma shot.
	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 1.28,--10 DPS more or less
	},
	customparams = {
		--heatgenerated		= "0",--0/s
		cegflare			= "MG_MUZZLEFLASH",
		weaponclass			= "projectile",
    },
	
	
}

return lowerkeys({ MG = weaponDef })