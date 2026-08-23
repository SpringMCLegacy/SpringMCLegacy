local resources = {
	{ -- north
		x =5708,
		z =745,
	},
	{ -- west
		x =5466,
		z =9515,
		feature = nil,
	},
	{ -- east
		x =8914,
		z =4324,
		feature = nil,
	},
	{ -- south
		x =1338,
		z =4650,
		feature = nil,
	},
	{ -- mid north
		x =5474,
		z =3322,
		feature = nil,
		points = 6,
	},
	{ -- mid south
		x =5235,
		z =6072,
		feature = nil,
		points = 6,
	},
}

local temps = {
	ambient = 12,
	water = 1,
}

local starts = {
	[0] = { -- teamID
		x = 556,
		z = 704,
		alwaysbeacon = 1,
	},
	[1] = { -- teamID
		x = 8677,
		z = 9070,
		alwaysbeacon = 1,
	},
	[2] = { -- teamID
		x = 9556,
		z = 700,
		alwaysbeacon = 1,
	},
	[3] = { -- teamID
		x = 1122,
		z = 9710,
		alwaysbeacon = 1,
	},
}

return resources, temps, starts
