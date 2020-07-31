-- Aircraft - Bombs

local Bomb = BombClass:New{
	model					= "Weapons/ArrowIV.s3o",
}

-- PTAB "Antitank Aviation Bomb" (RUS)
local PTAB = BombClass:New{
	--[[areaOfEffect			= 240,
	burst					= 36,
	burstrate				= 0.1,
	turret					= true,
	tolerance				= 5000,
	edgeEffectiveness		= 0.5,
	explosionGenerator		= "custom:HE_large", -- overrides default]]
	model					= "Weapons/ArrowIV.s3o",
	--[[weaponVelocity			= 200,
	leadlimit				= 100,
	name					= "Bombs",
	range					= 500,
	soundHitDry				= "GEN_Explode4",
	sprayangle				= 10000,--7000,
	customparams = {

	},
	damage = {
		default            = 2000,
	},]]
}

  

-- Return only the full weapons
return lowerkeys({
  Bomb = Bomb,
  PTAB = PTAB,
})
