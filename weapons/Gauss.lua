local Gauss_Class = Weapon:New{
	weaponType              = "Cannon",
	cegTag					= "RailTrail",
	turret                  = true,
	accuracy                = 250,
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
		weaponclass			= "gauss",
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
		default = 380,--320, --80 dps
	},
	customparams = {
		heatgenerated		= 0.4,
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
		default = 1100,--937.5, --150 DPS
	},
	customparams = {
		heatgenerated		= 0.6,
    },
}

local HeavyGauss = Gauss_Class:New{
	name                    = "H. Gauss Rifle",
	explosionGenerator    	= "custom:HeavyGauss_Hit",
	soundHit              	= "HeavyGauss_Hit",
	soundStart            	= "HeavyGauss_Fire",
	range                   = 2000,
	weaponVelocity          = 2500,
	reloadtime              = 8,
	DynDamageExp			= 1,
	DynDamageMin			= 1000,--100 DPS 
	--DynDamageRange			= 1300,--Weapon will decrease in damage up to this range
	
	damage = {
		default = 2160,--2500,--250 DPS
	},
	customparams = {
		heatgenerated		= 2,
		ammotype			= "hvgauss",
    },
}

local SilverBullet = Gauss:New{
	explosionGenerator    	= "custom:MG_Hit",
	impactOnly				= true,
	areaOfEffect            = 1,
	collisionSize			= 100,
	weaponVelocity          = 2000,
	size					= 0.8,
	soundHit              	= "AC2_Hit", -- TODO: Need a distinct sound really
	sprayAngle				= 300, -- 800
	dynDamageExp			= 1.0,
	
	range 					= 2200,
	projectiles				= 15,
	dynDamageMin			= 100,
	
	damage = {
		default = 150,
	},
	customparams = {
		weaponclass			= "lbx_cluster", -- needs to differ from base lbx as used to detect firing lbx weapons
    },	
}

return lowerkeys({ 
	LightGauss = LightGauss,
	Gauss = Gauss,
	HeavyGauss = HeavyGauss,
	SilverBullet = SilverBullet,
})