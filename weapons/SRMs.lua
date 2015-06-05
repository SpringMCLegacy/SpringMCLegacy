local SRM_Class = Weapon:New{
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
	range                   = 700,
	accuracy                = 1000,
	sprayangle				= 1750,
	wobble					= 900,
	dance					= 65,
	tracks					= true,
	turnRate				= 2000,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 5,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	damage = {
		default = 150,--10 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"missileEngine"},
		weaponclass			= "missile",
		jammable			= false,
		ammotype			= "srm",
    },
}

local SRM2 = SRM_Class:New{
	name                    = "SRM-2",
	burst					= 2,
	customparams = {
		heatgenerated		= "15",--3/sec
	}
}

local SRM4 = SRM_Class:New{
	name                    = "SRM-4",
	burst					= 4,
	customparams = {
		heatgenerated		= "15",--3/sec
	}
}

local SRM6 = SRM_Class:New{
	name                    = "SRM-6",
	burst					= 6,
	customparams = {
		heatgenerated		= "20",--4/sec
	}
}

return lowerkeys({ 
	SRM2 = SRM2,
	InfSRM2 = SRM2:New{range = 200},
	SRM4 = SRM4,
	SRM6 = SRM6,
})