local MRM_Class = Weapon:New{
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_SMALL",
	cegTag					= "MRMTrail",
	smokeTrail				= false,
	soundHit              	= "MRM_Hit",
	soundStart            	= "MRM_Fire",
	burnblow				= true, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1500,
	accuracy                = 100,
	sprayAngle				= 400,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 900,
	weaponVelocity          = 900,
	reloadtime              = 7.5,
	burstrate				= 0.01,
	model					= "Missile.s3o",
	damage = {
		default = 75,--10 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"missileEngine"},
		weaponclass			= "missile",
		jammable			= false,
		ammotype			= "mrm",
    },
}

local MRM10 = MRM_Class:New{
	name                    = "MRM-10",
	burst					= 10,
	customparams = {
		heatgenerated		= 3,
}

local MRM20 = MRM_Class:New{
	name                    = "MRM-20",
	burst					= 20,
	customparams = {
		heatgenerated		= 4.5,
    },
}

local MRM30 = MRM_Class:New{
	name                    = "MRM-30",
	burst					= 30,
	customparams = {
		heatgenerated		= 7.5,
    },
}

local MRM40 = MRM_Class:New{
	name                    = "MRM-40",
	burst					= 40,
	customparams = {
		heatgenerated		= 9,
    },
}

return lowerkeys({ 
	MRM10 = MRM10,
	MRM20 = MRM20,
	MRM30 = MRM30,
	MRM40 = MRM40,
})