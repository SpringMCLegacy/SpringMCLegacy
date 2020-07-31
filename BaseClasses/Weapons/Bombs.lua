-- Aircraft - Bombs

-- Bomb Base Class
local BombClass = Weapon:New{
	accuracy = 500,
	areaofeffect = 144,
	avoidfeature = false,
	--burst = 5,
	--burstrate = 0.3,
	collidefriendly = false,
	commandfire = false,
	craterareaofeffect = 144,
	craterboost = 0,
	cratermult = 0,
	edgeeffectiveness = 0.4,
	explosionGenerator		= "custom:HE_large",
	impulseboost = 0.5,
	impulsefactor = 0.5,
	model = "bomb",
	name = "Bombs",
	noselfdamage = true,
	range = 1280,
	reloadtime = 9,
	sprayangle = 300,
	weapontype = "AircraftBomb",
	damage = {
		default = 1000,
	},
	customParams = {
		ammotype			= "bomb",
	},
}

-- Return only the full weapons
return {
	BombClass = BombClass,
}
