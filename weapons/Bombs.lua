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
	model					= "Weapons/Bomblet.s3o",
	projectiles			= 96, -- https://www.sarna.net/wiki/File:Arrow4_Cluster.jpg
	sprayangle			= 600,
	damage = {
		default            = 3000,
	},
}
  

-- Return only the full weapons
return lowerkeys({
  Bomb = Bomb,
  Cluster = Cluster,
})
