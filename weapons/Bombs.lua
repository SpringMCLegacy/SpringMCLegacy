-- Aircraft - Bombs

local Bomb = BombClass:New{
	model					= "Weapons/ArrowIV.s3o",
	sprayangle				= 300,
	areaOfEffect			= 240,
	damage = {
		default            = 3000,
	},
}
}

-- PTAB "Antitank Aviation Bomb" (RUS)
local PTAB = BombClass:New{
	areaOfEffect			= 240,
	burst					= 36,
	burstrate				= 0.1,
	weaponType				= "Cannon",
	turret					= true,
	tolerance				= 5000,
	edgeEffectiveness		= 0.5,
	explosionGenerator		= "custom:HE_large",
	model					= "Weapons/ArrowIV.s3o",
	weaponVelocity			= 600,
	leadlimit				= 100,
	name					= "Bombs",
	range					= 500,
	soundHitDry				= "GEN_Explode4",
	sprayangle				= 10000,--7000,
	customparams = {

	},
	damage = {
		default            = 1000,
	},
}

  

-- Return only the full weapons
return lowerkeys({
  Bomb = Bomb,
  PTAB = PTAB,
})
