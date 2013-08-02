weaponDef = {
	name                    = "AutoCannon/20",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_LARGE",
	soundHit             	= [[AC20_Hit]],
	soundStart           	= [[AC20_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 900,
	accuracy                = 50,
	areaOfEffect            = 50,
	weaponVelocity          = 2000,
	reloadtime              = 2.5,
	renderType				= 1,
	size					= 2,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.2,
	damage = {
		default = 1000, --400 DPS
	},
	customparams = {
		heatgenerated		= "17.5",--7/sec
		cegflare			= "AC20_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac20",
    },	
}

return lowerkeys({ AC20 = weaponDef })