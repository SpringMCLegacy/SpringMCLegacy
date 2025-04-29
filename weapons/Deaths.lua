local Death_Class = Weapon:New{
	soundHit             	= "GEN_ExplodeDeath",
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
	alwaysVisible = true,
}

local DFA = Death_Class:New{
	soundHit             	= "dropship_stomp",
	explosionGenerator    	= "custom:mech_jump_dust",
	areaOfEffect			= 100,
	damage = {
		default = 100,
	},	
}

local Mine = Death_Class:New{
	name                    = "Mech Explosion",
	explosionGenerator    	= "custom:HE_large",
	areaOfEffect            = 100, -- has to be sufficiently large to hit unit centre from ground...
	damage = {
		default = 1000,
	},
}

return lowerkeys({ 
	MechExplode = MechExplode,
	MeltDown = MeltDown,
	DFA = DFA,
	Mine = Mine,
})