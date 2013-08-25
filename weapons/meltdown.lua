weaponDef = {
	name                    = "Fusion Core Meltdown",
	explosionGenerator    	= "custom:meltdown",
	soundHit             	= [[GEN_ExplodeDeath]],
	soundStart           	= [[GEN_ExplodeDeath]],
	ballistic				= 1,
	areaOfEffect            = 500,
	renderType				= 4,
	impulseBoost			= 0,
	impulseFactor			= 0,
	craterBoost				= 0,
	craterMult				= 0,
	damage = {
		default = 10000,
	},
}

return lowerkeys({ meltdown = weaponDef })