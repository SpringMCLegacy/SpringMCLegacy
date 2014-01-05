weaponDef = {
	name                    = "Ultra AC/5",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= [[AC5_Hit]],
	soundStart            	= [[AC5_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 2000,
	accuracy                = 50,
	areaOfEffect            = 10,
	weaponVelocity          = 3000,
	reloadtime              = 0.25,
	renderType				= 1,
	size					= 1,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 50, --200 DPS (2 x Rate of Fire)
	},
	customparams = {
		heatgenerated		= "0.56",--1.5/sec
		cegflare			= "AC5_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac5",
    },
}

return lowerkeys({ UAC5 = weaponDef })