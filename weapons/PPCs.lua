local PPC_Class = Weapon:New{
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:PPC",
	cegTag					= "PPCTrail",
	soundHit              	= "PPC_Hit",
	soundStart            	= "PPC_Fire",
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1800,
	accuracy                = 100,
	targetMoveError			= 0.05,
	movingAccuracy			= 500,
	areaOfEffect            = 10,
	weaponVelocity          = 2000,
	reloadtime              = 5,
	size					= 5,
	sizeDecay				= 0,
	separation				= 0.5, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
	AlphaDecay				= 0.5, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.55 0.65 1.0",
	intensity				= 0.5,
	damage = {
		default = 500, --100 DPS
	},
	customparams = {
		heatgenerated		= 75,--10/sec
		cegflare			= "PPC_MUZZLEFLASH",
		heatdamage			= 10,
		weaponclass			= "energy",
		lupsribbon			= {size = 3, width = 6, color = {0.55, 0.65, 1,0.6}, texture1 = ":c:bitmaps/ProjectileTextures/ppcshot.png"},
    },
}

local PPC = PPC_Class:New{
	name                    = "PPC",
}

local CERPPC = PPC_Class:New{
	name                    = "CERPPC",
	heightBoostFactor		= 0,
	range                   = 2300,
	damage = {
		default = 750, --150 DPS
	},
}

local ERPPC = PPC_Class:New{
	name                    = "ERPPC",
	range                   = 2300,
}

return lowerkeys({ 
	PPC = PPC,
	ERPPC = ERPPC,
	CERPPC = CERPPC,
})