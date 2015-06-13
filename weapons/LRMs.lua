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
	range                   = 3000,
	accuracy                = 2000,
	sprayangle				= 5000,
	wobble					= 2000,
	dance 					= 100,
	trajectoryHeight		= 1,
	tracks					= true,
	turnRate				= 2500,
	flightTime				= 10,
	weaponTimer				= 20,
	areaOfEffect            = 20,
	startVelocity			= 600,
	weaponVelocity          = 800,
	reloadtime              = 15,
	burstrate				= 0.1,
	model					= "Missile.s3o",
	damage = {
		default = 150,--10 DPS
	},
	customparams = {
		cegflare			= "MISSILE_MUZZLEFLASH",
		projectilelups		= {"missileEngine"},
		weaponclass			= "missile",
		ammotype			= "lrm",
		minrange			= 500,
    },
}

local LRM5 = LRM_Class:New{
	name                    = "LRM-5",
	burst					= 5,
	customparams = {
		heatgenerated		= 30, --6/sec
	},
}

local LRM10 = LRM_Class:New{
	name                    = "LRM-10",
	burst					= 10,
	customparams = {
		heatgenerated		= 60, --6/sec
    },
}	

local LRM15 = LRM_Class:New{
	name                    = "LRM-15",
	burst					= 15,
	customparams = {
		heatgenerated		= 75, --6/sec
    },
}

local LRM20 = LRM_Class:New{
	name                    = "A.LRM-20",
	burst					= 20,
	customparams = {
		heatgenerated		= 90, --6/sec
    },
}

local ALRM5 = LRM_Class:New{
	name                    = "A.LRM-5",
	turnRate				= 4000,
	burst					= 5,
	customparams = {
		heatgenerated		= 30, --6/sec
	},
}

local ALRM10 = LRM_Class:New{
	name                    = "A.LRM-10",
	turnRate				= 4000,
	burst					= 10,
	customparams = {
		heatgenerated		= 60, --6/sec
    },
}	

local ALRM15 = LRM_Class:New{
	name                    = "A.LRM-15",
	turnRate				= 4000,
	burst					= 15,
	customparams = {
		heatgenerated		= 75, --6/sec
    },
}

local ALRM20 = LRM_Class:New{
	name                    = "A.LRM-20",
	turnRate				= 4000,
	burst					= 20,
	customparams = {
		heatgenerated		= 90, --6/sec
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
})