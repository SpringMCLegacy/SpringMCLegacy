weaponDef = {
	name                    = "Gauss Rifle",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:Gauss_Hit",
	cegTag					= "RailTrail",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[Gauss_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 2200,
	accuracy                = 10,
	targetMoveError			= 0.01,
	areaOfEffect            = 5,
	weaponVelocity          = 4000,
	reloadtime              = 6,
	renderType				= 1,
	size					= 2,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 250, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.75 0.75 1.0",
	intensity				= 0.5,
	damage = {
		default = 1350, --225 DPS
	},
	customparams = {
		heatgenerated		= "6",--1/s
		cegflare			= "GAUSS_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "gauss",
    },
}

return lowerkeys({ Gauss = weaponDef })