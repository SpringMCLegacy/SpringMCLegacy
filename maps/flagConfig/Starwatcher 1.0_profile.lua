local resources = {
	{ -- center big
		x = 6216,
		z = 4069,
		feature = nil,
		radiusmult = 3,
		points = 0,
	},
	{ --north west
		x = 4290,
		z = 1015,
		feature = nil,
		points = 6,
		radiusmult = 1.5,
	},
	{ --north east
		x = 7713,
		z = 768,
		feature = nil,
		points = 6,
		radiusmult = 1.5,
	},
	{ --south west
		x = 4820,
		z = 7177,
		feature = nil,
		points = 6,
		radiusmult = 1.5,
	},
	{ --south east
		x = 8036,
		z =  7140,
		feature = nil,
		points = 6,
		radiusmult = 1.5,
	},
	{ --west
		x = 1327,
		z = 3887,
		feature = nil,
	},
	{ --east
		x = 10933,
		z = 4038,
		feature = nil,
	},

}

local temps = {
	ambient = 24,
	water = 12,
}

local starts = {
	[0] = { -- teamID 1
		x = 782,
		z = 644,
	},
	[1] = { -- teamID 2
		x = 11475,
		z = 7503,
	},
	[2] = { -- teamID 3
		x = 11563,
		z = 608,
		alwaysbeacon = true,
	},
	[3] = { -- teamID 4
		x = 778,
		z = 7514,
		alwaysbeacon = true,
	},
}

return resources, temps, starts
