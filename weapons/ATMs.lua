local ATM_Class = Weapon:New{
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_MEDIUM",
	cegTag					= "ATMTrail",
	smokeTrail				= false,
	soundHit              	= "ATM_Hit",
	soundStart            	= "ATM_Fire",
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 2700,--2700*0.6
	accuracy                = 2000,
	sprayangle				= 1000,
	wobble					= 1000,
	dance 					= 125,
	trajectoryHeight		= 0.5,
	tracks					= true,
	tolerance				= 3000,
	turnRate				= 2000,
	flightTime				= 10,
	weaponTimer				= 20,
	areaOfEffect            = 20,
	startVelocity			= 400,
	weaponVelocity          = 800,
	weaponAcceleration 		= 500,
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

local ATM_Short = ATM_Class:New{
	range                   = 600,
	trajectoryHeight		= 0,
	damage = {
		default = 300,--30 DPS
	},
}

local ATM_Mid = ATM_Class:New{
	range                   = 1500,
	trajectoryHeight		= 0.5,
	damage = {
		default = 200,--30 DPS
	},
	customparams = {
		minrange			= 600,
    },
}

local ATM_Long = ATM_Class:New{
	range                   = 2700,
	trajectoryHeight		= 1,
	damage = {
		default = 100,--30 DPS
	},
	customparams = {
		minrange			= 1500,
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
	ATM_Short = ATM_Short,
	ATM_Mid = ATM_Mid,
	ATM_Long = ATM_Long,
})