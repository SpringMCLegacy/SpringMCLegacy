local CruiseMissile = Weapon:New{
	name                    = "Cruise Missile",
	weaponType              = "StarburstLauncher",
	explosionGenerator    	= "custom:HE_XXXLARGE",
	cegTag					= "ArrowIVTrail",
	smokeTrail				= false,
	soundHit              	= [[Arrow_Hit]],
	soundStart            	= [[Arrow_Fire]],
--	soundTrigger			= 0,
	burnblow				= false, 	--Bullets explode at range limit.
	collideenemy 			= false,
	collidefeature 			= false,
	collidefriendly 		= false,
	commandfire = true,
	noSelfDamage            = true,
	range                   = 13000,
	accuracy                = 2000,
	tolerance				= 1000,
	--wobble					= 6000,
	dance					= 10,
	trajectoryHeight		= 0.75,
	tracks					= false,
	turnRate				= 0,
	weaponTimer				= 6,
	stockpile 				= true,
	stockpiletime 			= 120,
	--metalpershot 			= 10000, --c-bills per missile
	flightTime				= 150,
	areaOfEffect            = 2000,
	edgeEffectiveness		= 0.5,
	startVelocity			= 0,
	weaponAcceleration 		= 50,
	weaponVelocity          = 1000,
	reloadtime              = 10,
	model					= "Weapons/CruiseMissile.s3o",
	interceptedByShieldType	= 32,
	damage = {
		default = 10000,--200 DPS
	},
	customparams = {
		heatgenerated		= 10,--10/sec
		cegflare			= "ARROW_MUZZLEFLASH",
		projectilelups		= {"missileEngineLarge"},
		shockwave			= true,
    },
}

return lowerkeys({ 
	CruiseMissile = CruiseMissile,})