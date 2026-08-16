local Artillery_Class = Weapon:New{
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XLARGE",
	soundHit             	= [[Sniper_Hit]],
	soundStart           	= [[Sniper_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 4000,
	accuracy                = 500,
	tolerance				= 1000,
	areaOfEffect            = 400,
	weaponVelocity          = 650,
	reloadtime              = 10,
	size					= 3,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 75, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	explosionScar			= true,
	damage = {
		default = 1500, --100 dps
	},
	customparams = {
		heatgenerated		= 8,
		cegflare			= "ARTILLERY_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "sniper",
		shockwave			= true,
    },
}

local Mortar = Artillery_Class:New{
	name                    = "Auto-Mortar",
	explosionGenerator    	= "custom:HE_MEDIUM",
	soundHit              	= "Mortar_Hit",
	soundStart            	= "Mortar_Fire",
	highTrajectory			= 1,
	size					= 2,
	sizeDecay				= 0,
	separation				= 1.5,
	--burst					= 3,
	--burstrate				= 0.5,
	areaOfEffect            = 100,
	range                   = 1500,
	reloadtime              = 5,
	accuracy                = 100,
	weaponVelocity          = 750,
	myGravity				= 0.4,
	damage = {
		default = 500,
	},
	customparams = {
		heatgenerated		= 2,
		cegflare			= "AC5_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "mortar",
		shockwave			= false,
    },
}

local Sniper = Artillery_Class:New{
	name                    = "Sniper Cannon",
}

local Thumper = Artillery_Class:New{
	name                    = "Thumper Cannon",
	explosionGenerator    	= "custom:HE_XLARGE",
	soundHit             	= [[Thumper_Hit]],
	soundStart           	= [[Thumper_Fire]],
	range                   = 2500,
	weaponVelocity          = 450,
	areaOfEffect            = 300,
	accuracy                = 500,
	reloadtime              = 7,
	damage = {
		default = 1000, --50 dps
	},
		customparams = {
		heatgenerated		= 6,
    },
}

local LongTom = Artillery_Class:New{
	name                    = "Long Tom Cannon",
	explosionGenerator    	= "custom:HE_XXLARGE",
	soundHit             	= [[LongTom_Hit]],
	soundStart           	= [[LongTom_Fire]],
	range                   = 7500,
	weaponVelocity          = 950,
	areaOfEffect            = 650,
	accuracy                = 500,
	reloadtime              = 12,
	damage = {
		default = 2000, --
	},
		customparams = {
		heatgenerated		= 10,
    },
}

return lowerkeys({ 
	Mortar = Mortar,
	Sniper = Sniper,
	Thumper = Thumper,
	LongTom = LongTom,
})