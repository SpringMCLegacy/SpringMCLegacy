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
	range                   = 900,
	accuracy                = 1000,
	sprayangle				= 1750,
	wobble					= 900,
	dance					= 65,
	tracks					= true,
	turnRate				= 1200,
	weaponTimer				= 5,
	areaOfEffect            = 20,
	startVelocity			= 1000,
	weaponVelocity          = 1000,
	reloadtime              = 5,
	burstrate				= 0.1,
	model					= "Weapons/Missile.s3o",
	damage = {
		default = 110,--100,--20 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"srmEngine"},
		weaponclass			= "srm",
		jammable			= false,
		ammotype			= "srm",
    },
}

local SRM2 = SRM_Class:New{
	name                    = "SRM-2",
	burst					= 2,
	customparams = {
		heatgenerated		= 1,
	}
}

local SRM_Guided = SRM_Class:New{
	turnRate				= 40000,
}

local ASRM2 = SRM2:New{
	name                    = "Artemis SRM-2",
	turnRate				= 4000,
}

local InfSRM = SRM_Class:New{
	name                    = "Infantry SRM",
	range					= 200,
--	burst					= 1,
	turnRate				= 4000,
	customparams = {
		ammotype			= "infsrm",
	}
}

local InfSRM2 = SRM2:New{
	name                    = "Infantry SRM-2",
	range					= 200,
	turnRate				= 4000,
	customparams = {
		ammotype			= "infsrm",
	}
}

local SSRM_Class = Weapon:New{
	reloadtime              = 7.5,
	sprayangle				= 500,
	turnRate				= 10000,
	customparams = {
		jammable			= true,
		weaponclass			= "ssrm",
	}
}

local SSRM2 = SRM2:New(SSRM_Class):New{
	name                    = "Streak SRM-2",
}

local SRM4 = SRM_Class:New{
	name                    = "SRM-4",
	burst					= 4,
	customparams = {
		heatgenerated		= 1.5,
	}
}

local ASRM4 = SRM4:New{
	name                    = "Artemis SRM-4",
	turnRate				= 4000,
}

local SSRM4 = SRM4:New(SSRM_Class):New{
	name                    = "Streak SRM-4",
}

local SRM6 = SRM_Class:New{
	name                    = "SRM-6",
	burst					= 6,
	customparams = {
		heatgenerated		= 2,
	}
}

local ASRM6 = SRM6:New{
	name                    = "Artemis SRM-6",
	turnRate				= 4000,
}

local SSRM6 = SRM6:New(SSRM_Class):New{
	name                    = "Streak SRM-6",
}

return lowerkeys({ 
	SRM_Guided = SRM_Guided,
	SRM2 = SRM2,
	InfSRM = InfSRM,
	InfSRM2 = InfSRM2,
	SRM4 = SRM4,
	SRM6 = SRM6,
	SSRM2 = SSRM2,
	SSRM4 = SSRM4,
	SSRM6 = SSRM6,
	ASRM2 = ASRM2,
	ASRM4 = ASRM4,
	ASRM6 = ASRM6,
})