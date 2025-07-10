local PPC_Class = Weapon:New{
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:PPC",
	cegTag					= "PPCTrail",
	soundHit              	= "PPC_Hit",
	soundStart            	= "PPC_Fire",
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	range                   = 1080,--1800*0.6
	accuracy                = 300,
	areaOfEffect            = 50,
	weaponVelocity          = 3000,
	reloadtime              = 5,
	size					= 5,
	sizeDecay				= 0,
	separation				= 0.5, 		--Distance between each plasma particle.
	stages					= 50, 		--Number of particles used in one plasma shot.
	AlphaDecay				= 0.5, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "0.55 0.65 1.0",
	intensity				= 0.5,
	DynDamageExp			= 1,
	DynDamageMin			= 300,--1/2
	damage = {
		default = 600,--500, --100 DPS
	},
	customparams = {
		heatgenerated		= 5,
		cegflare			= "PPC_MUZZLEFLASH_2",
		heatdamage			= 1,
		weaponclass			= "ppc",
		projectilelups		= {"ppcTail"},
    },
}

local PPC_fx = Weapon:New{
	weaponType				= "LightningCannon",
	rgbcolor				= "0.15 0.88 1.0",
	damage 					= {
		default					= 1,
	}
}

local PPC = PPC_Class:New{
	name                    = "PPC",
	customparams = {
		minrange			= 200,
    },
}

local ERPPC = PPC_Class:New{
	name                    = "ERPPC",
	accuracy                = 300,
	range                   = 1380,--2300*0.6
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 200,
    },
}

local HeavyPPC = PPC_Class:New{
	name                    = "Heavy PPC",
	DynDamageExp			= 1,
	DynDamageMin			= 450,--1/2
	damage = {
		default = 900,--750, --150 DPS
	},
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 200,
    },
}

local LightPPC = PPC_Class:New{
	name                    = "Light PPC",
	DynDamageExp			= 1,
	DynDamageMin			= 150,--1/2
	damage = {
		default = 300,--250, --50 DPS
	},
	customparams = {
		heatgenerated		= 2.5,
		minrange			= 200,
    },
}

local SnubNosePPC = PPC_Class:New{
	name                    = "Snub-Nose PPC",
	range					= 720,--1200*0.6
	accuracy                = 200,
	targetMoveError			= 0.02,
	movingAccuracy			= 300,
	DynDamageExp			= 1,
	DynDamageMin			= 300,--100 DPS 
	DynDamageRange			= 600,
}

local CERPPC = PPC_Class:New{
	name                    = "CERPPC",
	heightBoostFactor		= 0,
	range                   = 1380,--2300*0.6
	DynDamageExp			= 1,
	DynDamageMin			= 450,--1/2
	damage = {
		default = 900,--750, --150 DPS
	},
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 200,
    },
}

local NPPC = PPC_Class:New{
	explosionGenerator    	= "custom:NPPC",
	soundStart            	= "NPPC_Fire",
	soundHit				= "NPPC_Hit",
	areaOfEffect            = 550,
	edgeEffectiveness		= 0.8,
	size					= 15,
	damage = {
		default = 2000,
	},
	customparams = {
		heatdamage			= 7,
		projectilelups		= {"nppcTail"},
	}
}

return lowerkeys({ 
	PPC = PPC,
	ERPPC = ERPPC,
	HeavyPPC = HeavyPPC,
	LightPPC = LightPPC,
	SnubNosePPC = SnubNosePPC,
	CERPPC = CERPPC,
	NPPC = NPPC,
	PPC_fx = PPC_fx,
})