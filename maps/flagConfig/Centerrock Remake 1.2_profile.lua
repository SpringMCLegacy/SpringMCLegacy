local resources = {
	{ --center
		x = 4230,
		z = 3750,
		feature = nil,
		radiusmult = 2.5,
		points = 0,	
	},
	{ --west plateau
		x = 1305,
		z = 3890,
		feature = nil,
		radius = 300,
		points = 6,	
	},
	{ --north plateau
		x = 4640,
		z = 1000,
		feature = nil,
		points = 0,
	},
	{ --south plateau
		x = 4375,
		z = 6600,
		feature = nil,
		points = 0,
	},
	{ --east plateau
		x = 7580,
		z = 2960,
		feature = nil,	
		radius = 300,
		points = 6,	
	},
	{ --northeast corner
		x = 7687,
		z = 299,
		feature = nil,	
		radius = 300,
	},
	{ --southwest corner
		x = 567,
		z = 6278,
		feature = nil,	
		radius = 300,
	},
}

local temps = {
	ambient = 22,
	water = 14,
}

local starts = {
	[0] = { -- teamID 1
		x = 2253,
		z = 433,
		alwaysbeacon = 1,
	},
	[1] = { -- teamID 2
		x = 6636,
		z = 7700,
		alwaysbeacon = 1,
	},
}

return resources, temps, starts
