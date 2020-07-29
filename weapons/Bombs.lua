-- Aircraft - Bombs

-- Implementations

-- timefuze
local timebombClass = BombClass:New{
  accuracy           = 2000,
  groundBounce	     = true,
  burnblow	     = false,
  collideEnemy     = false,
  edgeEffectiveness  = 0.2,
  --model              = [[Bomb_Medium.S3O]],
  soundHitDry        = [[GEN_Explo_9]],
  bounceRebound	     = 0.1,
  bounceSlip	     = 0.1,
  numBounce	     = 20,
}
-- 250Kg Bomb (Generic)
local Bomb = timebombClass:New{
  areaOfEffect       = 200,
  commandfire        = true,
  name               = [[250kg Bomb]],
  range              = 600,
  damage = {
    default            = 30000,
  },
}

-- 160Kg Bomb (Generic)
local Bomb160kg = timebombClass:New{
  areaOfEffect       = 160,
  fireTolerance	= 15000,
  tolerance          = 700,
  name               = [[160kg Bomb]],
  model              = [[Bomb_Medium.S3O]],
  range              = 450,
  commandfire        = false,
    damage = {
    default            = 15000,
    },
}


-- 100 kg bomb (generic)
local Bomb100kg = timebombClass:New{
  areaOfEffect       = 160,
  name               = [[100kg Bomb]],
  model              = [[Bomb_Medium.S3O]],
  range              = 550,
  commandfire        = false,
    damage = {
    default            = 10000,
    },
}

-- divebomb
local divebomb = BombClass:New{
  size		     = 1,
  accuracy           = 200,
  tolerance          = 100,	
  heightMod		= 1,
  mygravity	= 0.01,
  model              = [[Bomb_Medium.S3O]],
  explosionGenerator = [[custom:HE_Large]],
  soundHit           = [[GEN_Explo_5]],
}
-- 50Kg divebomb 
local Bomb50kg = divebomb:New{
  name               = [[50kg Bomb]],
  explosionGenerator = [[custom:HE_Medium]],
  soundHit           = [[GEN_Explo_4]],
  areaOfEffect       = 76,
    damage = {
    default            = 7500,
	planes		= 5,
    },
  range              = 500,
}

-- 250kg divebomb
local Bomb250kg = divebomb:New{
  name               = [[250kg Bomb]],
  areaOfEffect       = 156,
  commandfire        = true,
    damage = {
    default            = 27500,
	planes		= 5,
    },
  range              = 410,
}

-- PTAB "Antitank Aviation Bomb" (RUS)
local PTAB = divebomb:New{ --BombClass:New{
  areaOfEffect       = 240,
  burst              = 36,
  burstrate          = 0.1,
  --commandfire		= true,
  turret		= true,
  tolerance		= 5000,
  edgeEffectiveness  = 0.5,
  explosionGenerator = [[custom:HE_large]], -- overrides default
  model					= "Weapons/ArrowIV.s3o",
  weaponVelocity     = 200,
  leadlimit		= 100,
  name               = [[PTAB Anti-Tank Bomblets]],
  projectiles        = 8,
  range              = 500,
  soundHitDry        = [[GEN_Explo_3]],
  sprayangle         = 10000,--7000,
  customparams = {

  },
  damage = {
    default            = 2000,
	},
  }

  

-- Return only the full weapons
return lowerkeys({
  Bomb = Bomb,
  Bomb160kg = Bomb160kg,
  Bomb100kg = Bomb100kg,
  Bomb50kg = Bomb50kg,
  Bomb250kg = Bomb250kg,
  PTAB = PTAB,
})
