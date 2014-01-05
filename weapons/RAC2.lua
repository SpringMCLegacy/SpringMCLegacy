weaponDef = {
	name                    = "Rotary AC/2",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XSMALL",
	soundHit              	= [[AC2_Hit]],
	soundStart            	= [[AC2_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 25,
	sprayangle				= 25,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	burst					= 10,
	burstrate				= 0.04,
	reloadtime              = 0.4,
	renderType				= 1,
	size					= 0.75,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	damage = {
		default = 8, --200 DPS (5 x Rate of Fire)
	},
	customparams = {
		heatgenerated		= "4",--0.5/s
		cegflare			= "AC2_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac2",
		spinspeed			= "600",
		flareonshot 		= true,
    },
}

return lowerkeys({ RAC2 = weaponDef })