local MML_Class = Weapon:New{
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
		default = 200,--2 DPS per missile, down to 100 at minimum range
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"missileEngine"},
		weaponclass			= "missile",
		ammotype			= "mml",
    },
}

local MML3 = MML_Class:New{
	name                    = "MML 3",
	burst					= 3,
	customparams = {
		heatgenerated		= 2,
	}
}

local MML5 = MML_Class:New{
	name                    = "MML 5",
	burst					= 5,
	customparams = {
		heatgenerated		= 3,
	}
}

local MML7 = MML_Class:New{
	name                    = "MML 7",
	burst					= 7,
	customparams = {
		heatgenerated		= 4,
	}
}

local MML9 = MML_Class:New{
	name                    = "MML 9",
	burst					= 9,
	customparams = {
		heatgenerated		= 5,
	}
}

return lowerkeys({
	MML3 = MML3,
	MML5 = MML5,
	MML7 = MML7,
	MML9 = MML9,
})