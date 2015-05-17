local BeamLaser_Class = Weapon:New{
	weaponType				= "BeamLaser",
	beamBurst				= true,
	burstRate				= 0.01,
	explosionGenerator		= "custom:burn",
	--soundHit              	= [[GEN_Beam_Explode1]],
	soundTrigger			= true,
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
	range                   = 600,
	accuracy                = 150,	
	reloadtime              = 2.5,
	thickness				= 1,
	coreThickness			= 0.25,
	beamTime           		= 0.35,
	beamTTL           		= 0.35,
	burst					= 10,
	rgbcolor				= [[1.0 0.4 0.4]],
	damage = {
		default = 12.5, --30 DPS, 125 damage per reload
	},
	customparams = {
		heatgenerated		= 2.5,--1/sec
		cegflare			= "SMALLLASER_MUZZLEFLASH",
    },
}

local ERSBL = SBL:New{
	name                    = "ERSLaser",
	range                   = 700,
	customparams = {
		heatgenerated		= 5,--2/sec
    },
}

local CERSBL = ERSBL:New{
	name                    = "CERSLaser",
	range                   = 800,
	damage = {
		default = 20, --50 DPS
	},
}

local MBL = BeamLaser_Class:New{
	name                    = "MLaser",
	soundStart           	= [[MBL_Fire]],
	range                   = 900,
	accuracy                = 150,
	reloadtime              = 3,
	thickness				= 1.5,
	coreThickness			= 0.4,
	beamTime           		= 0.5,
	beamTTL           		= 0.5,
	burst					= 15,
	rgbcolor				= [[0.4 1.0 0.4]],
	damage = {
		default = 10,--10 DPS, 150 damage per reload
	},
	customparams = {
		heatgenerated		= 9,--3/sec
		cegflare			= "MEDIUMLASER_MUZZLEFLASH",
    },
}

local ERMBL = MBL:New{
	name                    = "ERMLaser",
	range                   = 1050,
	customparams = {
		heatgenerated		= 15,--5/sec
    },
}

local CERMBL = ERMBL:New{
	name                    = "CERMLaser",
	range                   = 1150,
	damage = {
		default = 14, --70 DPS, 210 damage per reload
	},
}

local LBL = BeamLaser_Class:New{
	name                    = "LLaser",
	soundStart           	= [[LBL_Fire]],
	range                   = 1500,
	accuracy                = 150,
	reloadtime              = 5,
	thickness				= 2,
	coreThickness			= 0.5,
	beamTime           		= 0.65,
	beamTTL           		= 0.65,
	burst					= 20,
	rgbcolor				= [[0.5 0.0 1.0]],
	damage = {
		default = 20, --80 DPS, 400 damage per reload
	},
	customparams = {
		heatgenerated		= 40,--8/sec
		cegflare			= "LARGELASER_MUZZLEFLASH",
    },
}

local ERLBL = LBL:New{
	name                    = "ERLLaser",
	range                   = 1600,
	customparams = {
		heatgenerated		= 60,--12/sec
    },
}

local CERLBL = ERLBL:New{
	name                    = "CERLLaser",
	range                   = 1700,
	damage = {
		default = 25, --200 DPS, 500 damage per reload
	},
}

return lowerkeys({ 
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