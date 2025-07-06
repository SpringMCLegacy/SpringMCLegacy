local PulseLaser_Class = Weapon:New{
	weaponType              = "BeamLaser",
	beamBurst				= true,
	laserFlareSize			= 0.1,
	explosionGenerator		= "custom:burn",
--	soundHit              	= [[GEN_Pulse_Explode1]],
	turret                  = true,
	tolerance				= 100,
	accuracy                = 300,
	areaOfEffect            = 5,
	weaponVelocity          = 2000,
	weaponTimer				= 0.8,
	beamTime           		= 0.01,
	beamTTL           		= 1,
	--burst					= 5,
	--burstrate				= 0.1,
	minIntensity			= 1,
	customparams = {
		weaponclass			= "energy",
		flareonshot 		= true,
    },
}

local SPL = PulseLaser_Class:New{
	name                    = "SPulseLaser",
	soundStart           	= [[SPL_Fire]],
	range                   = 300,--unchanged
	--accuracy                = 10,
	reloadtime              = 0.1,
	laserFlareSize			= 0.075,
	thickness				= 1,
	coreThickness			= 0.25,
	rgbcolor				= [[1.0 0.4 0.4]],
	intensity				= 0.5,
	damage = {
		default = 6,--10, --x 5 (burst) x 6 shots per 10 seconds = 300 damage
	},
	customparams = {
		heatgenerated		= 0.12,
		cegflare			= "SMALLLASER_MUZZLEFLASH",
    },
}

local CSPL = SPL:New{
	name                    = "CSPulseLaser",
	range                   = 450,--600,
}

local MicroSPL = SPL:New{
	name                    = "MicroPulseLaser",
	range                   = 200,
	rgbcolor				= [[0.2 0.2 1.0]],
	damage = {
		default = 5, --x 5 (burst) x 6 shots per 10 seconds = 150 damage
	},
}

local MPL = PulseLaser_Class:New{
	name                    = "MPulseLaser",
	soundStart           	= [[MPL_Fire]],
	range                   = 450,--600,
	--accuracy                = 25,
	reloadtime              = 0.1,
	thickness				= 1.5,
	coreThickness			= 0.4,
	rgbcolor				= [[0.4 0.8 0.4]],
	intensity				= 0.6,
	damage = {
		default = 12,--36.7, --x 5 (burst) x 3.3 shots per 10 seconds = 600 damage
	},
	customparams = {
		heatgenerated		= 0.25,
		cegflare			= "MEDIUMLASER_MUZZLEFLASH",
    },
}

local CMPL = MPL:New{
	name                    = "CMPulseLaser",
	range                   = 720,--1200*0.6
	damage = {
		default = 14,--42.4, --x 5 (burst) x 3.3 shots per 10 seconds = 700 damage
	},
}

local LPL = PulseLaser_Class:New{
	name                    = "LPulseLaser",
	soundStart           	= [[LPL_Fire]],
	range                   = 600,--1000*0.6
	--accuracy                = 50,
	areaOfEffect            = 10,
	reloadtime              = 0.1,
	thickness				= 2,
	coreThickness			= 0.5,
	rgbcolor				= [[0.4 0.0 0.8]],
	intensity				= 1,
	damage = {
		default = 18,--69, --x 5 (burst) x 2.6 shots per 10 seconds = 900 damage
	},
	customparams = {
		heatgenerated		= 1,--10/sec
		cegflare			= "LARGELASER_MUZZLEFLASH",
    },
}

local CLPL = LPL:New{
	name                    = "CLPulseLaser",
	range                   = 1200,--2000*0.6
	damage = {
		default = 20,--77, --x 5 (burst) x 2.6 shots per 10 seconds = 1000 damage
	},
}

return lowerkeys({ 
	SPL = SPL,
	MicroSPL = MicroSPL,
	CSPL = CSPL,
	MPL = MPL,
	CMPL = CMPL,
	LPL = LPL,
	CLPL = CLPL,
})