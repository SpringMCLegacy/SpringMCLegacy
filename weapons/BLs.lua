local BeamLaser_Class = Weapon:New{
	weaponType				= "BeamLaser",
	beamBurst				= true,
	burstRate				= 0.01,
	explosionGenerator		= "custom:burn",
	--soundHit              	= [[GEN_Beam_Explode1]],
	soundTrigger			= true,
	accuracy                = 500,
	tolerance				= 100,
	turret                  = true,
	targetMoveError			= 0.1,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	laserFlareSize			= 0.1,
	minIntensity			= 1,
	intensity				= 0.75,
	
	customparams = {
		weaponclass			= "energy",
		flareonshot 		= true,
    },
}

local Sight = BeamLaser_Class:New{
	range = 5000, -- should be more than enough
	avoidFriendly = false, -- don't let friendly mechs block LOS calcs
	collideFriendly = false,
	avoidNeutral = false,
	collideNeutral = false,
	collideEnemy = false,
	avoidFeature = false,
	collideFeature = false,
	
	areaOfEffect = 500,
	accuracy     = 5,
	
	customparams = {
		weaponclass = "sight",
		ignoreingui	= true,
	},
}

local TAG = BeamLaser_Class:New{
	name                    = "TAG Laser",
	explosionGenerator    	= "custom:Nothing",
	soundStart           	= [[TAG_Fire]],
	canAttackGround			= false,
	range                   = 1500,
	accuracy                = 50,
	reloadtime              = 0.1,
	thickness				= 0.75,
	coreThickness			= 0.1,
	beamTime           		= 0.5,
	beamTTL           		= 0.5,
	burst					= 10,
	rgbcolor				= [[1.0 0.4 0.4]],
	intensity				= 0.25,
	damage = {
		default = 0.0000001, 
	},
	customparams = {
		heatgenerated		= 0,
		cegflare			= "SMALLLASER_MUZZLEFLASH",
		flareonshot			= true,
		tag					= true,
    },
}

local SBL = BeamLaser_Class:New{
	name                    = "SLaser",
	soundStart           	= [[SBL_Fire]],
	range                   = 300,
	--accuracy                = 150,	
	reloadtime              = 2.5,
	thickness				= 1,
	coreThickness			= 0.25,
	beamTime           		= 0.35,
	beamTTL           		= 0.35,
	burst					= 10,
	rgbcolor				= [[1.0 0.4 0.4]],
	damage = {
		default = 7.5,--x 10 (burst) x 4 times per 10 seconds = 300 damage
	},
	customparams = {
		heatgenerated		= 0.25,--0.1/sec
		cegflare			= "SMALLLASER_MUZZLEFLASH",
    },
}

local ERSBL = SBL:New{
	name                    = "ERSLaser",
	range                   = 500,
	customparams = {
		heatgenerated		= 0.5,--0.2/sec
    },
}

local CERSBL = ERSBL:New{
	name                    = "CERSLaser",
	range                   = 600,
	damage = {
		default = 12.5--x 10 (burst) x 4 times per 10 seconds = 500 damage
	},
}

local MBL = BeamLaser_Class:New{
	name                    = "MLaser",
	soundStart           	= [[MBL_Fire]],
	range                   = 900,
	--accuracy                = 150,
	reloadtime              = 3.3,
	thickness				= 1.5,
	coreThickness			= 0.4,
	beamTime           		= 0.5,
	beamTTL           		= 0.5,
	burst					= 10,
	rgbcolor				= [[0.4 1.0 0.4]],
	damage = {
		default = 16.6,-- x 10 (burst) x 3 shots per 10 seconds = 500 damage
	},
	customparams = {
		heatgenerated		= 1,--0.3/sec
		cegflare			= "MEDIUMLASER_MUZZLEFLASH",
    },
}

local ERMBL = MBL:New{
	name                    = "ERMLaser",
	range                   = 1200,
	customparams = {
		heatgenerated		= 1,--0.5/sec
    },
}

local CERMBL = ERMBL:New{
	name                    = "CERMLaser",
	range                   = 1500,
	damage = {
		default = 23.3,-- x 10 (burst) x 3 shots per second = 700 damage
	},
}

local LBL = BeamLaser_Class:New{
	name                    = "LLaser",
	soundStart           	= [[LBL_Fire]],
	range                   = 1500,
	--accuracy                = 150,
	reloadtime              = 5,
	thickness				= 2,
	coreThickness			= 0.5,
	beamTime           		= 0.65,
	beamTTL           		= 0.65,
	burst					= 15,
	rgbcolor				= [[0.5 0.0 1.0]],
	damage = {
		default = 26.6, --x 15 (burst) x 2 shots per 10 seconds = 800 damage
	},
	customparams = {
		heatgenerated		= 4,--0.8/sec
		cegflare			= "LARGELASER_MUZZLEFLASH",
    },
}

local ERLBL = LBL:New{
	name                    = "ERLLaser",
	range                   = 1900,
	customparams = {
		heatgenerated		= 6,--1.2/sec
    },
}

local CERLBL = ERLBL:New{
	name                    = "CERLLaser",
	range                   = 2500,
	damage = {
		default = 33.3, --x 15 (burst) x 2 shots per 10 seconds = 1000 damage
	},
}

return lowerkeys({ 
	Sight = Sight,
	TAG = TAG,
	SBL = SBL,
	ERSBL = ERSBL,
	CERSBL = CERSBL,
	MBL = MBL,
	ERMBL = ERMBL,
	CERMBL = CERMBL,
	LBL = LBL,
	ERLBL = ERLBL,
	CERLBL = CERLBL,
})