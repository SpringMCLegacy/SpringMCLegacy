weaponDef = {
	name                    = "LBX/20 AutoCannon",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:MG_Hit",
	soundHit              	= [[GEN_Explode1]],
	soundStart            	= [[LBX20_Fire]],
	soundTrigger			= 1,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 900,
	accuracy                = 250,
	areaOfEffect            = 1,
	weaponVelocity          = 1200,
	reloadtime              = 2.5,
	burst					= 5,
	burstrate				= 0.00001,
	sprayAngle				= 200,
	projectiles				= 4,
	renderType				= 1,
	size					= 0.5,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 25, --200 DPS
		beacons = 0,
		light = 25,
		medium = 21.25,
		heavy = 17.5,
		assault = 12.5,
		vehicle = 37.5,
	},
	customparams = {
		heatgenerated		= "30",--6/sec
		cegflare			= "AC20_MUZZLEFLASH",
    },
}

return lowerkeys({ LBX20 = weaponDef })