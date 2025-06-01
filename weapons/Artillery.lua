local Artillery_Class = Weapon:New{
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XLARGE",
	soundHit             	= [[Sniper_Hit]],
	soundStart           	= [[Sniper_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 7000,
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
	damage = {
		default = 2000, --100 dps
	},
	customparams = {
		heatgenerated		= 20,
		cegflare			= "ARTILLERY_MUZZLEFLASH",
		weaponclass			= "projectile",
		ammotype			= "sniper",
		shockwave			= true,
    },
}

local Sniper = Artillery_Class:New{
	name                    = "Sniper Artillery Cannon",
}

local Thumper = Artillery_Class:New{
	name                    = "Thumper Artillery Cannon",
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

return lowerkeys({ 
	Sniper = Sniper,
	Thumper = Thumper,
})