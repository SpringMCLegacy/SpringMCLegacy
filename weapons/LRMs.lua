local LRM_Class = Weapon:New{
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_SMALL",
	--cegTag					= "LRMTrail",
	soundHit              	= "LRM_Hit",
	soundStart            	= "LRM_Fire",
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 2100,
	accuracy                = 2000,
	sprayangle				= 5000,
	wobble					= 2000,
	dance 					= 100,
	trajectoryHeight		= 1,
	tracks					= true,
	turnRate				= 3000,
	flightTime				= 10,
	weaponTimer				= 20,
	areaOfEffect            = 20,
	startVelocity			= 600,
	weaponVelocity          = 800,
	reloadtime              = 10,
	burstrate				= 0.1,
	model					= "Weapons/LargeMissile.s3o",
	damage = {
		default = 100,--10 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"missileEngine"},
		weaponclass			= "lrm",
		ammotype			= "lrm",
		minrange			= 600,
    },
}

local LRM_Guided = LRM_Class:New{
	turnRate				= 40000,
}

local LRM5 = LRM_Class:New{
	name                    = "LRM-5",
	burst					= 5,
	customparams = {
		heatgenerated		= 3,
	},
}

local LRM10 = LRM_Class:New{
	name                    = "LRM-10",
	burst					= 10,
	customparams = {
		heatgenerated		= 6,
    },
}	

local LRM15 = LRM_Class:New{
	name                    = "LRM-15",
	burst					= 15,
	customparams = {
		heatgenerated		= 7.5,
    },
}

local LRM20 = LRM_Class:New{
	name                    = "LRM-20",
	burst					= 20,
	customparams = {
		heatgenerated		= 9,
    },
}

local ALRM5 = LRM_Class:New{
	name                    = "A.LRM-5",
	turnRate				= 4000,
	burst					= 5,
	customparams = {
		heatgenerated		= 3,
	},
}

local ALRM10 = LRM_Class:New{
	name                    = "A.LRM-10",
	turnRate				= 4000,
	burst					= 10,
	customparams = {
		heatgenerated		= 6,
    },
}	

local ALRM15 = LRM_Class:New{
	name                    = "A.LRM-15",
	turnRate				= 4000,
	burst					= 15,
	customparams = {
		heatgenerated		= 7.5,
    },
}

local ALRM20 = LRM_Class:New{
	name                    = "A.LRM-20",
	turnRate				= 4000,
	burst					= 20,
	customparams = {
		heatgenerated		= 9,
    },
}

local AirLRM_Class = LRM_Class:New{ --Air-launched LRMs don't need to fire at upwards angles
	trajectoryHeight		= 0,
}

local AirLRM5 = AirLRM_Class:New{
	name                    = "LRM-5",
	turnRate				= 4000,
	burst					= 5,
	customparams = {
		heatgenerated		= 3,
	},
}

local AirLRM10 = AirLRM_Class:New{
	name                    = "LRM-10",
	turnRate				= 4000,
	burst					= 10,
	customparams = {
		heatgenerated		= 6,
    },
}	

local AirLRM15 = AirLRM_Class:New{
	name                    = "LRM-15",
	turnRate				= 4000,
	burst					= 15,
	customparams = {
		heatgenerated		= 7.5,
    },
}

local AirLRM20 = AirLRM_Class:New{
	name                    = "LRM-20",
	turnRate				= 4000,
	burst					= 20,
	customparams = {
		heatgenerated		= 9,
    },
}

return lowerkeys({ 
	LRM5 = LRM5,
	LRM10 = LRM10,
	LRM15 = LRM15,
	LRM20 = LRM20,
	ALRM5 = ALRM5,
	ALRM10 = ALRM10,
	ALRM15 = ALRM15,
	ALRM20 = ALRM20,
	AirLRM5 = AirLRM5,
	AirLRM10 = AirLRM10,
	AirLRM15 = AirLRM15,
	AirLRM20 = AirLRM20,
	LRM_Guided = LRM_Guided,
})