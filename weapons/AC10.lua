weaponDef = {
	name                    = "AutoCannon/10",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_MEDIUM",
	soundHit              	= [[GEN_Explode3]],
	soundStart            	= [[AC10_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1500,
	accuracy                = 25,
	areaOfEffect            = 25,
	weaponVelocity          = 1500,
	reloadtime              = 1.5,
	renderType				= 1,
	size					= 1.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 150, --100 DPS
		beacons = 0,
		light = 150,
		medium = 127.5,
		heavy = 105,
		assault = 75,
		vehicle = 225,
	},
	customparams = {
		heatgenerated		= "2",--3/sec
		cegflare			= "AC10_MUZZLEFLASH",
    },
}

return lowerkeys({ AC10 = weaponDef })