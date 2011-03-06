weaponDef = {
	name                    = "Rotary AutoCannon/2",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XSMALL",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[AC2_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 25,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	reloadtime              = 0.04,
	renderType				= 1,
	size					= 0.75,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 4, --100 DPS
		beacons = 0,
		light = 4,
		medium = 3.4,
		heavy = 2.8,
		assault = 2,
		vehicle = 6,
	},
	customparams = {
		heatgenerated		= "0.1",--0.5/s
		cegflare			= "AC2_MUZZLEFLASH",
    },
}

return lowerkeys({ RAC2 = weaponDef })