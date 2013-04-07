weaponDef = {
	name                    = "Heavy Gauss Rifle",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_MEDIUM",
	cegTag					= "RailTrail",
	soundHit              	= [[GEN_Explode2]],
	soundStart            	= [[HeavyGauss_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 10,
	targetMoveError			= 0.01,
	areaOfEffect            = 5,
	weaponVelocity          = 2500,
	reloadtime              = 12,
	renderType				= 1,
	size					= 2,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 250, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.75 0.75 1.0",
	intensity				= 0.5,
	--DynDamageExp			= 1,
	--DynDamageMin			= 1200,--100 DPS 
	--DynDamageRange			= 1200,--Weapon will decrease in damage up to this range
	damage = {
		default = 4500,--375 DPS
	},
	customparams = {
		heatgenerated		= "24",--1/s
		cegflare			= "GAUSS_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "gauss",
    },
}

return lowerkeys({ HeavyGauss = weaponDef })