weaponDef = {
	name                    = "Ultra AutoCannon/5",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= [[GEN_Explode2]],
	soundStart            	= [[AC5_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 2000,
	accuracy                = 650,
	areaOfEffect            = 10,
	weaponVelocity          = 1000,
	reloadtime              = 0.375,
	renderType				= 1,
	size					= 1,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 25, --75 DPS, 25% increased Rate Of Fire
	},
	
	
	
}

return lowerkeys({ UAC5 = weaponDef })