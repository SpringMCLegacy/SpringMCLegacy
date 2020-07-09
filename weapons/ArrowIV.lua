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
	accuracy                = 2000,
	tolerance				= 1000,
	wobble					= 6000,
	--dance					= 50,
	trajectoryHeight		= 0.75,
	tracks					= false,
	turnRate				= 2000,
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
		weaponclass			= "missile",
		ammotype			= "arrow",
		shockwave			= true,
    },
}

local ArrowIV_Guided = ArrowIV:New{
	name                    = "Homing Arrow Missile",
	wobble					= 100,
	trajectoryHeight		= 1,
	tracks					= false,
	turnRate				= 500,	
	customparams = {
		minrange			= 300,
    },
}

return lowerkeys({ 
	ArrowIV = ArrowIV,
	ArrowIV_Guided = ArrowIV_Guided,
	})