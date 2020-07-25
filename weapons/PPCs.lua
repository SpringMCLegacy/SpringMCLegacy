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
	range                   = 1800,
	accuracy                = 400,
	targetMoveError			= 0.05,
	movingAccuracy			= 200,
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
	damage = {
		default = 600,--500, --100 DPS
	},
	customparams = {
		heatgenerated		= 5,
		cegflare			= "ccssfxexpand",--PPC_MUZZLEFLASH",
		heatdamage			= 1,
		weaponclass			= "ppc",
		projectilelups		= {"ppcTail"},
    },
}

local PPC = PPC_Class:New{
	name                    = "PPC",
	customparams = {
		minrange			= 300,
    },
}

local ERPPC = PPC_Class:New{
	name                    = "ERPPC",
	accuracy                = 300,
	range                   = 2300,
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 200,
    },
}

local HeavyPPC = PPC_Class:New{
	name                    = "Heavy PPC",
	damage = {
		default = 900,--750, --150 DPS
	},
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 300,
    },
}

local LightPPC = PPC_Class:New{
	name                    = "Light PPC",
	damage = {
		default = 300,--250, --50 DPS
	},
	customparams = {
		heatgenerated		= 2.5,
		minrange			= 300,
    },
}

local SnubNosePPC = PPC_Class:New{
	name                    = "Snub-Nose PPC",
	range					= 1500,
	accuracy                = 300,
	targetMoveError			= 0.05,
	movingAccuracy			= 200,
	DynDamageExp			= 1,
	DynDamageMin			= 300,--100 DPS 
}

local CERPPC = PPC_Class:New{
	name                    = "CERPPC",
	heightBoostFactor		= 0,
	range                   = 2300,
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
})