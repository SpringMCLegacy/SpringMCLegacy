local Gauss_Class = Weapon:New{
	weaponType              = "Cannon",
	cegTag					= "RailTrail",
	turret                  = true,
	accuracy                = 100,
	impactOnly				= true,
	targetMoveError			= 0.01,
	weaponVelocity          = 4000,
	size					= 2,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 250, 		--Number of particles used in one plasma shot.
	rgbcolor				= [[0.75 0.75 1.0]],
	intensity				= 0.5,
	
	customparams = {
		cegflare			= "GAUSS_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "gauss",
    },
}
	
local LightGauss = Gauss_Class:New{
	name                    = "L. Gauss Rifle",
	explosionGenerator    	= "custom:LightGauss_Hit",
	soundHit              	= "LightGauss_Hit",
	soundStart            	= "LightGauss_Fire",
	range                   = 2500,
	reloadtime              = 4,
	size					= 1.5,
	stages					= 200, 		--Number of particles used in one plasma shot.
	damage = {
		default = 480, --120 DPS
	},
	customparams = {
		heatgenerated		= 4,
		ammotype			= "ltgauss",
    },
}

local Gauss = Gauss_Class:New{
	name                    = "Gauss Rifle",
	explosionGenerator    	= "custom:Gauss_Hit",
	soundHit              	= "Gauss_Hit",
	soundStart            	= "Gauss_Fire",
	range                   = 2200,
	reloadtime              = 6,

	damage = {
		default = 1350, --225 DPS
	},
	customparams = {
		heatgenerated		= 6,
    },
}

local HeavyGauss = Gauss_Class:New{
	name                    = "H. Gauss Rifle",
	explosionGenerator    	= "custom:HeavyGauss_Hit",
	soundHit              	= "HeavyGauss_Hit",
	soundStart            	= "HeavyGauss_Fire",
	range                   = 1800,
	weaponVelocity          = 2500,
	reloadtime              = 12,
	--DynDamageExp			= 1,
	--DynDamageMin			= 1200,--100 DPS 
	--DynDamageRange			= 1200,--Weapon will decrease in damage up to this range
	
	damage = {
		default = 4500,--375 DPS
	},
	customparams = {
		heatgenerated		= 24,
		ammotype			= "hvgauss",
    },
}

local HAG30 = HeavyGauss:New{
	name                    = "HAG 30",
	explosionGenerator    	= "custom:MG_Hit",
	soundHit              	= "GEN_Explode1",
	accuracy                = 200,
	areaOfEffect            = 1,
	reloadtime              = 5,
	sprayAngle				= 100,
	projectiles				= 30,
	size					= 0.5,
	stages					= 50, 		--Number of particles used in one plasma shot.
	damage = {
		default = 100, --600 DPS
	},
	customparams = {
		heatgenerated		= 30,
    },
}

return lowerkeys({ 
	LightGauss = LightGauss,
	Gauss = Gauss,
	HeavyGauss = HeavyGauss,
	HAG30 = HAG30,
})