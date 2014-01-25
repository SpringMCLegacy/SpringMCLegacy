weaponDef = {
	name                    = "CERPPC",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:PPC",
	--cegTag					= "PPCTrail",
	soundHit              	= [[PPC_Hit]],
	soundStart            	= [[PPC_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	heightBoostFactor		= 0,
	range                   = 2300,
	accuracy                = 100,
	targetMoveError			= 0.05,
	movingAccuracy			= 500,
	areaOfEffect            = 10,
	weaponVelocity          = 2000,
	reloadtime              = 5,
	size					= 5,
	--sizeDecay				= 0.4,
	separation				= 0.5, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
	AlphaDecay				= 0.5, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.55 0.65 1.0",
	intensity				= 0.5,
	damage = {
		default = 750, --150 DPS
	},
	customparams = {
		heatgenerated		= "75",--15/sec
		cegflare			= "PPC_MUZZLEFLASH",
		heatdamage			= "10",
		weaponclass			= "energy",
    },
}

return lowerkeys({ CERPPC = weaponDef })