weaponDef = {
	name                    = "Rotary AutoCannon/5",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= [[AC5_Hit]],
	soundStart            	= [[AC5_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1500,
	accuracy                = 25,
	sprayangle				= 250,
	areaOfEffect            = 10,
	weaponVelocity          = 1750,
	burst					= 8,
	burstrate				= 0.1,
	reloadtime              = 0.8,
	renderType				= 1,
	size					= 1,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 50, --500 DPS (5 x Rate of Fire)
	},
	customparams = {
		heatgenerated		= "4",--1/sec
		cegflare			= "MISSILE_MUZZLEFLASH",--"AC5_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac5",
		spinspeed			= "600",
    },	
}

return lowerkeys({ RAC5 = weaponDef })