weaponDef = {
	name                    = "LBX/20 AutoCannon",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
--	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LBX20_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 700,
	accuracy                = 250,
	areaOfEffect            = 1,
	weaponVelocity          = 2500,
	reloadtime              = 5,
	sprayAngle				= 400,
	projectiles				= 20,
	renderType				= 1,
	size					= 0.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
--	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 150, --600 DPS
	},
	customparams = {
		heatgenerated		= "30",--6/sec
		cegflare			= "AC20_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "ac20",
    },
}

return lowerkeys({ LBX20 = weaponDef })