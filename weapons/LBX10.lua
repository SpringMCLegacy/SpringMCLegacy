weaponDef = {
	name                    = "LBX/10 AutoCannon",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LBX10_Fire]],
	soundTrigger			= 1,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 1500,
	accuracy                = 250,
	areaOfEffect            = 1,
	weaponVelocity          = 1500,
	reloadtime              = 1.5,
	burst					= 5,
	burstrate				= 0.00001,
	sprayAngle				= 200,
	projectiles				= 2,
	renderType				= 1,
	size					= 0.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 15, --100 DPS
		beacons = 0,
		light = 15,
		medium = 13.5,
		heavy = 12,
		assault = 10.5,
		vehicle = 22.5,
	},
	customparams = {
		heatgenerated		= "3",--2/sec
		cegflare			= "AC10_MUZZLEFLASH",
    },
}

return lowerkeys({ LBX10 = weaponDef })