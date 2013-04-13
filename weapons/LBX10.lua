weaponDef = {
	name                    = "LBX/10 AutoCannon",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
--	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LBX10_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1500,
	accuracy                = 250,
	areaOfEffect            = 1,
	weaponVelocity          = 2500,
	reloadtime              = 3,
	sprayAngle				= 300,
	projectiles				= 10,
	renderType				= 1,
	size					= 0.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
--	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	dynDamageExp			= 1.0,
	dynDamageMin			= 45,
	damage = {
		default = 90, --300 DPS
	},
	customparams = {
		heatgenerated		= "3",--2/sec
		cegflare			= "AC10_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac10",
    },
}

return lowerkeys({ LBX10 = weaponDef })