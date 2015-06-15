local ATM_Class = Weapon:New{
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_MEDIUM",
	cegTag					= "ATMTrail",
	smokeTrail				= false,
	soundHit              	= "ATM_Hit",
	soundStart            	= "ATM_Fire",
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 3200,
	accuracy                = 500,
	sprayangle				= 1000,
	wobble					= 1000,
	dance 					= 100,
	trajectoryHeight		= 0.5,
	tracks					= true,
	turnRate				= 2000,
	flightTime				= 10,
	weaponTimer				= 20,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 10,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	DynDamageExp			= 1,
	DynDamageMin			= 100,--100 DPS 
	--DynDamageRange			= 1200,--Weapon will decrease in damage up to this range
	damage = {
		default = 200,--15 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"missileEngine"},
		weaponclass			= "missile",
		ammotype			= "atm",
    },
}

local ATM3 = ATM_Class:New{
	name                    = "ATM 3",
	burst					= 3,
	customparams = {
		heatgenerated		= "20", --6/sec
	}
}

local ATM6 = ATM_Class:New{
	name                    = "ATM 6",
	burst					= 6,
	customparams = {
		heatgenerated		= "40", --6/sec
	}
}

local ATM9 = ATM_Class:New{
	name                    = "ATM 9",
	burst					= 9,
	customparams = {
		heatgenerated		= "60", --6/sec
	}
}

local ATM12 = ATM_Class:New{
	name                    = "ATM 12",
	burst					= 12,
	customparams = {
		heatgenerated		= "80", --6/sec
	}
}

return lowerkeys({
	ATM3 = ATM3,
	ATM6 = ATM6,
	ATM9 = ATM9,
	ATM12 = ATM12,
})