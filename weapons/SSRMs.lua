local SSRM_Class = Weapon:New{
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_MEDIUM",
	cegTag					= "SRMTrail",
	smokeTrail				= false,
	soundHit              	= "SRM_Hit",
	soundStart            	= "SRM_Fire",
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 800,
	accuracy                = 100,
	wobble					= 700,
	dance					= 45,
	tracks					= true,
	turnRate				= 10000,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 600,
	reloadtime              = 7.5,
	burstrate				= 0.1,
	sprayAngle 				= 100,
	model					= "Missile.s3o",
	damage = {
		default = 150,--10 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"srmEngine"},
		weaponclass			= "missile",
		ammotype			= "srm",
    },
}

local SSRM2 = SSRM_Class:New{
	name                    = "Streak SRM-2",
	burst					= 2,
	customparams = {
		heatgenerated		= 22.5,--3/sec	
	}
}

local SSRM4 = SSRM_Class:New{
	name                    = "Streak SRM-4",
	burst					= 4,
	customparams = {
		heatgenerated		= 22.5,--3/sec	
	}
}

local SSRM6 = SSRM_Class:New{
	name                    = "Streak SRM-6",
	burst					= 6,
	customparams = {
		heatgenerated		= 30,--4/sec	
	}
}

return lowerkeys({
	SSRM2 = SSRM2,
	SSRM4 = SSRM4,
	SSRM6 = SSRM6,
})