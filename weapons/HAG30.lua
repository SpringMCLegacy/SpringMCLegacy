weaponDef = {
	name                    = "Hyper-Assault Gauss 30",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LightGauss_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1800,
	accuracy                = 200,
	areaOfEffect            = 1,
	weaponVelocity          = 2500,
	reloadtime              = 5,
	sprayAngle				= 100,
	projectiles				= 30,
	renderType				= 1,
	size					= 0.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.75 0.75 1.0",
	intensity				= 0.5,
	damage = {
		default = 50, --300 DPS
	},
	customparams = {
		heatgenerated		= "30",--6/sec
		cegflare			= "GAUSS_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "gauss",
    },
}

return lowerkeys({ HAG30 = weaponDef })