weaponDef = {
	name                    = "AutoCannon/5 with Flak Ammo",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= [[GEN_Explode_Flak]],
	soundStart            	= [[AC5_Fire]],
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 25,
	areaOfEffect            = 50,
	edgeEffectiveness		= 1,
	weaponVelocity          = 2000,
	reloadtime              = 0.5,
	renderType				= 1,
	size					= 1,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 25, --50 DPS
		vtol	= 50, --200% of default
	},
	customparams = {
		heatgenerated		= "0.5",--1/sec
		cegflare			= "AC5_MUZZLEFLASH",
    },	
}

return lowerkeys({ AC5_AA = weaponDef })