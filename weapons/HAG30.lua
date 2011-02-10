weaponDef = {
	name                    = "LBX/20 AutoCannon",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:Bullet",
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
	weaponVelocity          = 2000,
	reloadtime              = 5,
	burst					= 2,
	burstrate				= 0.00001,
	sprayAngle				= 100,
	projectiles				= 15,
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
    },
}

return lowerkeys({ HAG30 = weaponDef })