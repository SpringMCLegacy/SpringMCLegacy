weaponDef = {
	name                    = "AutoCannon/5",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= [[GEN_Explode2]],
	soundStart            	= [[AC5_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 25,
	areaOfEffect            = 10,
	weaponVelocity          = 1750,
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
		beacons = 0,
		light = 25,
		medium = 22.5, --90% of default
		heavy = 20, --80% of default
		assault = 17.5, --70% of default
		vehicle = 37.5, --150% of default
	},
	customparams = {
		heatgenerated		= "0.5",--1/sec
		cegflare			= "AC5_MUZZLEFLASH",
    },	
}

return lowerkeys({ AC5 = weaponDef })