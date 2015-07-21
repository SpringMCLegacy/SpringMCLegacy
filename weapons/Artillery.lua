local Artillery_Class = Weapon:New{
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XLARGE",
	soundHit             	= [[Sniper_Hit]],
	soundStart           	= [[Sniper_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 10000,
	accuracy                = 350,
	tolerance				= 1000,
	areaOfEffect            = 200,
	weaponVelocity          = 1500,
	reloadtime              = 20,
	size					= 3,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 75, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 4000, --100 dps
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
	reloadtime              = 10,
	damage = {
		default = 1500, --50 dps
	},
		customparams = {
		heatgenerated		= 6,
    },
}

return lowerkeys({ 
	Sniper = Sniper,
	Thumper = Thumper,
})