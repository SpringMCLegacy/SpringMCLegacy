local PulseLaser_Class = Weapon:New{
	weaponType              = "BeamLaser",
	beamBurst				= true,
	laserFlareSize			= 0.1,
	lineOfSight				= true,
	explosionGenerator		= "custom:burn",
--	soundHit              	= [[GEN_Pulse_Explode1]],
	turret                  = true,
	tollerance				= 100,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	burst					= 5,
	burstrate				= 0.1,
	minIntensity			= 1,
	customparams = {
		weaponclass			= "energy",
		flareonshot 		= true,
    },
}

local SPL = PulseLaser_Class:New{
	name                    = "SPulseLaser",
	soundStart           	= [[SPL_Fire]],
	range                   = 400,
	accuracy                = 10,
	reloadtime              = 1.65,
	laserFlareSize			= 0.075,
	thickness				= 1,
	coreThickness			= 0.25,
	rgbcolor				= [[1.0 0.4 0.4]],
	intensity				= 0.5,
	damage = {
		default = 9.9, --30 DPS, 49.5 damage per reload
	},
	customparams = {
		heatgenerated		= 0.66,--2/sec
		cegflare			= "SMALLLASER_MUZZLEFLASH",
    },
}

local CSPL = SPL:New{
	name                    = "CSPulseLaser",
	range                   = 500,
}

local MPL = PulseLaser_Class:New{
	name                    = "MPulseLaser",
	soundStart           	= [[MPL_Fire]],
	range                   = 700,
	accuracy                = 25,
	reloadtime              = 3,
	thickness				= 1.5,
	coreThickness			= 0.4,
	rgbcolor				= [[0.4 0.8 0.4]],
	intensity				= 0.6,
	damage = {
		default = 36, --60 DPS, 180 damage per reload
	},
	customparams = {
		heatgenerated		= 2.4,--4/sec
		cegflare			= "MEDIUMLASER_MUZZLEFLASH",
    },
}

local CMPL = MPL:New{
	name                    = "CMPulseLaser",
	range                   = 800,
	damage = {
		default = 42, --70 DPS, 210 damage per reload
	},
}

local LPL = PulseLaser_Class:New{
	name                    = "LPulseLaser",
	soundStart           	= [[LPL_Fire]],
	range                   = 1000,
	accuracy                = 50,
	areaOfEffect            = 10,
	reloadtime              = 3.75,
	thickness				= 2,
	coreThickness			= 0.5,
	rgbcolor				= [[0.4 0.0 0.8]],
	intensity				= 1,
	damage = {
		default = 67.5, --90 DPS, 337.5 damage per reload
	},
	customparams = {
		heatgenerated		= 7.5,--10/sec
		cegflare			= "LARGELASER_MUZZLEFLASH",
    },
}

local CLPL = LPL:New{
	name                    = "CLPulseLaser",
	range                   = 1100,
	damage = {
		default = 75, --100 DPS, 375 damage per reload
	},
}

return lowerkeys({ 
	SPL = SPL,
	CSPL = CSPL,
	MPL = MPL,
	CMPL = CMPL,
	LPL = LPL,
	CLPL = CLPL,
})