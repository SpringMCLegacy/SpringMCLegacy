weaponDef = {
	name                    = "LBX/5",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
--	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LBX5_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 100,
	areaOfEffect            = 1,
	weaponVelocity          = 2500,
	reloadtime              = 1,
	sprayAngle				= 200,
	projectiles				= 5,
	renderType				= 1,
	size					= 0.8,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
--	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	dynDamageExp			= 1.0,
	dynDamageMin			= 30,
	damage = {
		default = 60, --150 DPS
	},
	customparams = {
		heatgenerated		= "1",--1/sec
		cegflare			= "AC5_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac5",
    },
}

return lowerkeys({ LBX5 = weaponDef })