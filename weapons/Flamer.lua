weaponDef = {
	name                    = "Flamethrower",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:Flamethrower",
	cegTag					= "Flametrail",
	soundHit              	= [[MG_Hit]],
	soundStart            	= [[Flamer_Fire]],
	soundTrigger			= 1,
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= false,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 300,
	accuracy                = 100,
	areaOfEffect            = 1,
	weaponVelocity          = 250,
	reloadtime              = 2,
	--groundBounce			= 1,
	burst					= 5,
	burstrate				= 0.1,
	sprayAngle 				= 100,
	size					= 0.5,
	separation				= 1, 		--Distance between each plasma particle.
	stages					= 10, 		--Number of particles used in one plasma shot.
	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 9, --20 DPS
	},
	customparams = {
		heatgenerated		= "6",--3/s
		cegflare			= "LASER_MUZZLEFLASH",
		heatdamage			= "2.5",
		weaponclass			= "energy",
    },
}

return lowerkeys({ Flamer = weaponDef })