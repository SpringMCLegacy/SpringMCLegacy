weaponDef = {
	name                    = "Mech Explosion",
	explosionGenerator    	= "custom:ROACHPLOSION",
	soundHit             	= [[GEN_ExplodeDeath]],
	soundStart           	= [[GEN_ExplodeDeath]],
	ballistic				= 1,
	areaOfEffect            = 100,
	renderType				= 4,
	impulseBoost			= 0,
	impulseFactor			= 0,
	craterBoost				= 0,
	craterMult				= 0,
	damage = {
		default = 1000,
		beacons = 0,
	},
}

return lowerkeys({ mechexplode = weaponDef })