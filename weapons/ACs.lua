local AC_Class = Weapon:New{
	weaponType              = "Cannon",
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 40, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.1,
	customparams = {
		weaponclass			= "autocannon",
    },	
}

local LBX_Class = Weapon:New{
	explosionGenerator    	= "custom:MG_Hit",
	impactOnly				= true,
	areaOfEffect            = 1,
	collisionSize			= 100,
	weaponVelocity          = 2000,
	size					= 0.8,
	range					= 500,
	rgbcolor				= "1.0 0.6 0", -- slightly more orange for visual differentiation
	soundHit              	= "AC2_Hit", -- TODO: Need a distinct sound really
	sprayAngle				= 300, -- 800
	stages					= 5, 		--Number of particles used in one plasma shot.
	intensity				= 0.5,
	dynDamageExp			= 1.0,
	customparams = {
		weaponclass			= "lbx_cluster", -- needs to differ from base lbx as used to detect firing lbx weapons
    },	
}

-- AC2 & Variants
local AC2 = AC_Class:New{
	name                    = "AC/2",
	collisionSize			= 10,
	explosionGenerator    	= "custom:HE_XSMALL",
	soundHit              	= "AC2_Hit",
	soundStart            	= "AC2_Fire",
	range                   = 2400,
	accuracy                = 300,
	impactOnly				= true,
	weaponVelocity          = 4000,
	reloadtime              = 0.5,
	size					= 1,
	damage = {
		default = 25,--20,--10, --20 DPS
	},
	customparams = {
		heatgenerated		= 0.05,--0.1/second
		cegflare			= "AC2_MUZZLEFLASH",
		ammotype			= "ac2",
    },
}

local RAC2 = AC2:New{
	name                    = "Rotary AC/2",
	range                   = 1800,
	sprayangle				= 75,
	weaponVelocity          = 2000,
	burst					= 6,
	burstrate				= 0.04,
	reloadtime              = 0.5,
	customparams = {
		--heatgenerated		= 0.3,--0.5/s
		spinspeed			= 600,
		flareonshot 		= true,
    },
}

local UAC2 = AC2:New{
	name                    = "Ultra AC/2",
	range					= 2500,
	reloadtime              = 0.25,
}

local LBX2 = AC2:New{
	name                    = "LBX/2",
	soundStart            	= "AC2_Fire",
	range                   = 2700,
	--accuracy                = 100,
	reloadtime              = 2,
	
	customparams = {
		weaponclass			= "lbx",
		heatgenerated		= 0.05,--0.1/sec
    },
}

local LBX2_Cluster = LBX2:New(LBX_Class):New{
	--sprayAngle				= 700,
	range 					= 700,
	projectiles				= 2,
	dynDamageMin			= 100,
	
	damage = {
		default = 150,--20, --50 DPS
	},
}

-- AC5 & Variants
local AC5 = AC_Class:New{
	name                    = "AC/5",
	explosionGenerator    	= "custom:HE_SMALL",
	soundHit              	= "AC5_Hit",
	soundStart            	= "AC5_Fire",
	range                   = 1800,
	accuracy                = 400,
	impactOnly				= true,
	weaponVelocity          = 2000,
	reloadtime              = 2.5,
	size					= 1.2,
	damage = {
		default = 200,--100, --50 DPS
	},
	customparams = {
		heatgenerated		= 0.3,--0.1/sec --up from 0.2
		cegflare			= "AC5_MUZZLEFLASH",
		ammotype			= "ac5",
    },
}

local TCAC5 = AC5:New{
	name                    = "AC/5",
	accuracy                = 300,
}

local AC5_AA = AC5:New{
	name                    = "AC/5 Flak",
	burnblow				= true, 	--Bullets explode at range limit.
	impactOnly 				= false,
	--accuracy                = 25,
	weaponVelocity          = 3000,
	areaOfEffect      		= 100,
	explosionSpeed			= 1000,
	collisionSize			= 15,
	edgeEffectiveness		= 25,
	reloadtime              = 0.5,
	damage = {
		default = 40,--20, --50 DPS
		vtol	= 80,--40,
	},
}

local RAC5 = AC5:New{
	name                    = "Rotary AC/5",
	range                   = 1500,
	--accuracy                = 550,
	sprayangle				= 1000,
	weaponVelocity          = 1750,
	burst					= 6,
	burstrate				= 0.1,
	reloadtime              = 2,
	customparams = {
		heatgenerated		= 0.2,--0.2/sec
		--cegflare			= "MISSILE_MUZZLEFLASH",
		spinspeed			= 600,
		flareonshot 		= true,
    },	
}

local UAC5 = AC5:New{
	name                    = "Ultra AC/5",
	range                   = 2000,
	--accuracy                = 100,
	reloadtime              = 1,
	customparams = {
		heatgenerated		= 0.4,--0.1/sec
    },
}

local LBX5 = AC5:New{
	name                    = "LBX/5",
	soundStart            	= "LBX5_Fire",
	range                   = 1400,
	--accuracy                = 100,
	reloadtime              = 2,
	
	customparams = {
		weaponclass			= "lbx",
		heatgenerated		= 0.4,--0.1/sec
    },
}

local LBX5_Cluster = LBX5:New(LBX_Class):New{
	--sprayAngle				= 700,
	range 					= 700,
	projectiles				= 5,
	dynDamageMin			= 100,
	
	damage = {
		default = 150,--20, --50 DPS
	},
}

-- AC10 & Variants
local AC10 = AC_Class:New{
	name                    = "AC/10",
	explosionGenerator    	= "custom:HE_MEDIUM",
	soundHit              	= "AC10_Hit",
	soundStart            	= "AC10_Fire",
	range                   = 1500,
	accuracy                = 500,
	areaOfEffect            = 25,
	weaponVelocity          = 2000,
	reloadtime              = 4,
	size					= 1.8,
	stages					= 50, 		--Number of particles used in one plasma shot.
	damage = {
		default = 800,--400, --100 DPS
	},
	customparams = {
		heatgenerated		= 1.2,--3/sec
		cegflare			= "AC10_MUZZLEFLASH",
		ammotype			= "ac10",
    },
}

local UAC10 = AC10:New{
	name                    = "Ultra AC/10",
	range					= 1800,
	reloadtime              = 2,
}

local LBX10 = AC10:New{
	name                    = "LBX/10",
	soundStart            	= "LBX10_Fire",
	range                   = 1200,
	--accuracy                = 200,
	reloadtime              = 4,

	customparams = {
		weaponclass			= "lbx",
		heatgenerated		= 1.2,--3/sec
    },
}

local LBX10_Cluster = LBX10:New(LBX_Class):New{
	--sprayAngle				= 600,
	range					= 600,
	projectiles				= 10,
	dynDamageMin			= 100,
	
	damage = {
		default = 150,--40, --50 DPS
	},
}

-- AC20 & Variants
local AC20 = AC_Class:New{
	name                    = "AC/20",
	explosionGenerator    	= "custom:HE_LARGE",
	soundHit             	= "AC20_Hit",
	soundStart           	= "AC20_Fire",
	range                   = 900,
	accuracy                = 600,
	areaOfEffect            = 50,
	weaponVelocity          = 2000,
	reloadtime              = 5,
	size					= 2.4,
	stages					= 50, 		--Number of particles used in one plasma shot.
	intensity				= 0.2,
	damage = {
		default = 2000,--1000, --200 DPS
	},
	customparams = {
		heatgenerated		= 3.5,--7/sec
		cegflare			= "AC20_MUZZLEFLASH",
		ammotype			= "ac20",
		shockwave			= true,
    },
}

local UAC20 = AC20:New{
	name                    = "Ultra AC/20",
	range                   = 1000,
	reloadtime              = 2.5,
}

local AirAC20 = AC20:New{
	name                    = "AC/20",
	range                   = 1500,
	reloadtime              = 3.5,
}

local LBX20 = AC20:New{
	name                    = "LBX/20",
	soundStart            	= "LBX20_Fire",
	range                   = 800,
	--accuracy                = 150,
	reloadtime              = 5,
	customparams = {
		weaponclass			= "lbx",
		heatgenerated		= 3,--6/sec
    },
}

local LBX20_Cluster = LBX20:New(LBX_Class):New{
	--sprayAngle				= 400,
	range					= 400;
	projectiles				= 20,
	dynDamageMin			= 100,
	
	damage = {
		default = 150,--100, --600 DPS
	},
	customparams = {
		shockwave = false,
	},
}

-- Naval AC's for Orbital Strike
local NAC10 = AC_Class:New{
	explosionGenerator    	= "custom:HE_LARGE",
	soundHit             	= "NAC10_Hit",
	soundStart           	= "NAC10_Fire",
	areaOfEffect            = 500,
	edgeEffectiveness		= 0.75,
	size					= 5,
	stages					= 50, 		--Number of particles used in one plasma shot.
	intensity				= 0.2,
	damage = {
		default = 2000,
	},
	customparams = {
		shockwave			= true,
    },
}

local NAC40 = AC_Class:New{
	explosionGenerator    	= "custom:HE_LARGE",
	soundHit             	= "NAC40_Hit",
	soundStart           	= "NAC40_Fire",
	areaOfEffect            = 700,
	edgeEffectiveness		= 0.6,
	size					= 8,
	stages					= 50, 		--Number of particles used in one plasma shot.
	intensity				= 0.2,
	damage = {
		default = 3000,
	},
	customparams = {
		shockwave			= true,
    },
}

-- Return the weapons
return lowerkeys({ 
	-- AC2 & Variants
	AC2 = AC2,
	RAC2 = RAC2,
	UAC2 = UAC2,
	LBX2 = LBX2,
	LBX2_Cluster = LBX2_Cluster,
	-- AC5 & Variants
	AC5 = AC5,
	AC5_AA = AC5_AA,
	RAC5 = RAC5,
	UAC5 = UAC5,
	TCAC5 = TCAC5,
	LBX5 = LBX5,
	LBX5_Cluster = LBX5_Cluster,
	-- AC10 & Variants
	AC10 = AC10,
	UAC10 = UAC10,
	LBX10 = LBX10,
	LBX10_Cluster = LBX10_Cluster,
	-- AC20 & Variants
	AC20 = AC20,
	UAC20 = UAC20,
	LBX20 = LBX20,
	LBX20_Cluster = LBX20_Cluster,
	AirAC20 = AirAC20,
	--Naval Autocannons
	NAC10 = NAC10,
	NAC40 = NAC40,
})