-- Aircraft - Bombs

local Bomb = BombClass:New{
	model					= "Weapons/ArrowIV.s3o",
	sprayangle				= 300,
	areaOfEffect			= 240,
	damage = {
		default            = 3000,
	},
}

local Cluster = Bomb:New{
	model				= "Weapons/Bomblet.s3o",
	explosionGenerator    	= "custom:HE_MEDIUM",
	projectiles			= 96, -- https://www.sarna.net/wiki/File:Arrow4_Cluster.jpg
	sprayangle			= 600,
	areaOfEffect            = 200,
	damage = {
		default            = 500,
	},
}
 
local Thunder = Cluster:New{
	model					= "Weapons/Mine.s3o",
	explosionGenerator    	= "custom:MG_HIT",
	areaOfEffect            = 1,
	damage = {
		default            	= 1,
	},
} 

-- Return only the full weapons
return lowerkeys({
  Bomb = Bomb,
  Cluster = Cluster,
  Thunder = Thunder,
})
