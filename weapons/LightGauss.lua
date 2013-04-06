weaponDef = {
	name                    = "Light Gauss Rifle",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XSMALL",
	cegTag					= "RailTrail",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LightGauss_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 2500,
	accuracy                = 10,
	targetMoveError			= 0.01,
	areaOfEffect            = 3,
	weaponVelocity          = 4000,
	reloadtime              = 4,
	renderType				= 1,
	size					= 1.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 200, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.75 0.75 1.0",
	intensity				= 0.5,
	damage = {
		default = 320, --80 DPS
	},
	customparams = {
		heatgenerated		= "4",--1/sec
		cegflare			= "GAUSS_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "gauss",
    },
}

return lowerkeys({ LightGauss = weaponDef })