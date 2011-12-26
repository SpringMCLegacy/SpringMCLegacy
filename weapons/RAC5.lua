weaponDef = {
	name                    = "Rotary AutoCannon/5",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= [[GEN_Explode2]],
	soundStart            	= [[AC5_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1500,
	accuracy                = 25,
	areaOfEffect            = 10,
	weaponVelocity          = 1750,
	reloadtime              = 0.1,
	renderType				= 1,
	size					= 1,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 25, --250 DPS (5 x Rate of Fire)
	},
	customparams = {
		heatgenerated		= "0.5",--1/sec
		cegflare			= "AC5_MUZZLEFLASH",
    },	
}

return lowerkeys({ RAC5 = weaponDef })