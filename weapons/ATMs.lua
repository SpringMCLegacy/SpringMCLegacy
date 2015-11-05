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
	range                   = 2700,
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
	model					= "Weapons/Missile.s3o",
	DynDamageExp			= 1,
	DynDamageMin			= 100,--100 DPS 
	--DynDamageRange			= 1200,--Weapon will decrease in damage up to this range
	damage = {
		default = 300,--2 DPS per missile, down to 100 at minimum range
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
		heatgenerated		= 2,
	}
}

local ATM6 = ATM_Class:New{
	name                    = "ATM 6",
	burst					= 6,
	customparams = {
		heatgenerated		= 4,
	}
}

local ATM9 = ATM_Class:New{
	name                    = "ATM 9",
	burst					= 9,
	customparams = {
		heatgenerated		= 6,
	}
}

local ATM12 = ATM_Class:New{
	name                    = "ATM 12",
	burst					= 12,
	customparams = {
		heatgenerated		= 8,
	}
}

return lowerkeys({
	ATM3 = ATM3,
	ATM6 = ATM6,
	ATM9 = ATM9,
	ATM12 = ATM12,
})