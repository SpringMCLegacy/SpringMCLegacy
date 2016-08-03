weaponDef = {
    weaponType         = [[LaserCannon]],
	name               = "Flamethrower",
    accuracy           = 100,
    areaOfEffect       = 100,
    avoidFeature       = false,
    avoidFriendly      = false,
    --collideFeature     = false,
    --collideFriendly    = false,
	explosionGenerator = "custom:Flamethrower",
    coreThickness      = 0,
    duration           = 1,
    fallOffRate        = 1,
    fireStarter        = 100,
	--soundHit           = [[MG_Hit]],
	soundStart         = [[Flamer_Fire]],
	soundTrigger	   = 1,
    minintensity       = 0.1,
    impulseFactor      = 0,
    range              = 500,
    reloadtime         = 0.1,
    rgbColor           = "0 0 0",
    rgbColor2          = "0 0 0",
    thickness          = 0,
    tolerance          = 1000,
    turret             = true,
    weaponVelocity     = 1000,
	
	damage = {
		default = 0, --20 DPS
	},
	customparams = {
		heatgenerated		= 0.035,--0.1/s
		cegflare			= "flamethrowerrange500",
		heatdamage			= 0.075,
		weaponclass			= "energy",
		flareonshot 		= true,
		projectilelups		= {"flameHeat"},
    },
}

return lowerkeys({ Flamer = weaponDef })