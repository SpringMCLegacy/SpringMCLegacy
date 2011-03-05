weaponDef = {
	name                    = "Ultra AutoCannon/20",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_LARGE",
	soundHit             	= [[GEN_Explode4]],
	soundStart           	= [[AC20_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1050,
	accuracy                = 50,
	areaOfEffect            = 50,
	weaponVelocity          = 1000,
	reloadtime              = 1.25,
	renderType				= 1,
	size					= 2,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.2,
	damage = {
		default = 500, --400 DPS, 2x ROF
		beacons = 0,
		light = 500,
		medium = 425,
		heavy = 350,
		assault = 250,
		vehicle = 750,
	},
	customparams = {
		heatgenerated		= "17.5",--10.5/sec
    },	
}

return lowerkeys({ UAC20 = weaponDef })