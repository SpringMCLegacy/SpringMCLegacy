local Death_Class = Weapon:New{
	soundHit             	= "GEN_ExplodeDeath",
	soundStart           	= "GEN_ExplodeDeath",
	impulseBoost			= 0,
	impulseFactor			= 0,
	craterBoost				= 0,
	craterMult				= 0,
}

local MechExplode = Death_Class:New{
	name                    = "Mech Explosion",
	explosionGenerator    	= "custom:ROACHPLOSION",
	areaOfEffect            = 100,
	damage = {
		default = 1000,
	},
}

local MeltDown = Death_Class:New{
	name                    = "Fusion Core Meltdown",
	explosionGenerator    	= "custom:meltdown",
	areaOfEffect            = 500,
	damage = {
		default = 10000,
	},	
}

return lowerkeys({ 
	MechExplode = MechExplode,
	MeltDown = Meltdown,
})