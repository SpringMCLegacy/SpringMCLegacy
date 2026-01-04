local ArrowIV = Weapon:New{
	name                    = "Arrow Missile",
	weaponType              = "MissileLauncher",
	explosionGenerator    	= "custom:HE_XLARGE",
	cegTag					= "ArrowIVTrail",
	smokeTrail				= false,
	soundHit              	= [[Arrow_Hit]],
	soundStart            	= [[Arrow_Fire]],
--	soundTrigger			= 0,
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 4000,
	accuracy                = 1000,
	tolerance				= 1000,
	--wobble					= 6000,
	dance					= 10,
	trajectoryHeight		= 0.75,
	tracks					= false,
	turnRate				= 0,
	weaponTimer				= 10,
	flightTime				= 10,
	areaOfEffect            = 500,
	edgeEffectiveness		= 0.5,
	startVelocity			= 10,
	weaponAcceleration 		= 500,
	weaponVelocity          = 1000,
	reloadtime              = 10,
	model					= "Weapons/ArrowIV.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 2000,--200 DPS
	},
	customparams = {
		heatgenerated		= 10,--10/sec
		cegflare			= "ARROW_MUZZLEFLASH",
		projectilelups		= {"missileEngineLarge"},
		weaponclass			= "arrowiv",
		ammotype			= "arrow",
		shockwave			= true,
		minrange			= 720,
    },
}

local ArrowIV_Guided = ArrowIV:New{
	name                    = "Homing Arrow Missile",
	--wobble					= 100,
	trajectoryHeight		= 1.5,
	tracks					= true,
	turnRate				= 5000,	
	customparams = {
		minrange			= 300,
    },
}

local ADArrow = ArrowIV:New{
	name                    = "ADA Missile",
	canAttackGround 		= false,
	wobble					= 0,
	accuracy                = 100,
	flightTime				= 10,
	weaponTimer				= 10,
	burnblow				= true,
	trajectoryHeight		= 1,
	tracks					= true,
	turnRate				= 7000,	
	startVelocity			= 100,
	weaponAcceleration 		= 700,
	weaponVelocity          = 1500,
	model					= "Weapons/ArrowIV_AD.s3o",
}

local ArrowIV_Cluster = ArrowIV:New{
	model					= "Weapons/ArrowIV_Cluster.s3o",
	explosionGenerator    	= "custom:HE_SMALL",
	damage = {
		default = 100, -- all the bewm bewm is gone
	},
	customparams = {
		shockwave			= false,
	},
}

return lowerkeys({ 
	ArrowIV = ArrowIV,
	ArrowIV_Guided = ArrowIV_Guided,
	ADArrow = ADArrow,
	ArrowIV_Cluster = ArrowIV_Cluster,
	})