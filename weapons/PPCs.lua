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
	accuracy                = 100,
	targetMoveError			= 0.05,
	movingAccuracy			= 500,
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
		default = 500, --100 DPS
	},
	customparams = {
		heatgenerated		= 5,
		cegflare			= "ccssfxexpand",--PPC_MUZZLEFLASH",
		heatdamage			= 10,
		weaponclass			= "energy",
		projectilelups		= {"ppcTail"},
		minrange			= 300,
    },
}

local PPC = PPC_Class:New{
	name                    = "PPC",
}

local ERPPC = PPC_Class:New{
	name                    = "ERPPC",
	range                   = 2300,
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 150,
    },
}

local HeavyPPC = PPC_Class:New{
	name                    = "Heavy PPC",
	customparams = {
		heatgenerated		= 7.5,
    },
}

local LightPPC = PPC_Class:New{
	name                    = "Light PPC",
	damage = {
		default = 250, --50 DPS
	},
	customparams = {
		heatgenerated		= 2.5,
    },
}

local SnubNosePPC = PPC_Class:New{
	name                    = "Snub-Nose PPC",
	range					= 1500,
	DynDamageExp			= 1,
	DynDamageMin			= 250,--100 DPS 
	DynDamageRange			= 900,--Weapon will decrease in damage up to this range
}

local CERPPC = PPC_Class:New{
	name                    = "CERPPC",
	heightBoostFactor		= 0,
	range                   = 2300,
	damage = {
		default = 750, --150 DPS
	},
	customparams = {
		heatgenerated		= 7.5,
		minrange			= 150,
    },
}

return lowerkeys({ 
	PPC = PPC,
	ERPPC = ERPPC,
	HeavyPPC = HeavyPPC,
	LightPPC = LightPPC,
	SnubNosePPC = SnubNosePPC,
	CERPPC = CERPPC,
})