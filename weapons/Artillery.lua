local Artillery_Class = Weapon:New{
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XLARGE",
	soundHit             	= [[Sniper_Hit]],
	soundStart           	= [[Sniper_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 4500,
	accuracy                = 350,
	tolerance				= 1000,
	areaOfEffect            = 400,
	weaponVelocity          = 1000,
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
		default = 2000, --100 dps
	},
	customparams = {
		heatgenerated		= 8,
		cegflare			= "ARTILLERY_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "sniper",
		shockwave			= true,
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
	weaponVelocity          = 550,
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
	accuracy                = 200,
	reloadtime              = 15,
	damage = {
		default = 3000, --
	},
		customparams = {
		heatgenerated		= 10,
    },
}

return lowerkeys({ 
	Sniper = Sniper,
	Thumper = Thumper,
	LongTom = LongTom,
})