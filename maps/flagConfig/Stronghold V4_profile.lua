local resources = {
	{ --top west
		x = 3400,
		z = 750,
		feature = nil,
		points = 6,	
	},
	{ --top east
		x = 4650,
		z = 1650,
		feature = nil,
		radius = 300,
	},
	{ --west top
		x = 1550,
		z = 3650,
		feature = nil,
		radius = 300,
	},
	{ --west bottom
		x = 750,
		z = 4700,
		feature = nil,
		points = 6,	
	},
	{ --east top
		x = 7450,
		z = 3450,
		feature = nil,
		points = 6,	
	},
	{ --east bottom
		x = 6630,
		z = 4790,
		feature = nil,
		radius = 300,
	},
	{ --bottom west
		x = 3390,
		z = 6650,
		feature = nil,
		radius = 300,
	},
	{ --bottom east
		x = 4650,
		z = 7500,
		feature = nil,
		points = 6,	
	},
	{ --mid
		x = 4080,
		z = 4160,
		feature = nil,
		radiusmult = 1.5,
		points = 0,	
	},
}

local temps = {
	ambient = 24,
	water = 16,
}

local starts = {
	[0] = { -- teamID
		x = 1180,
		z = 820,
	},
	[1] = { -- teamID
		x = 6979,
		z = 7515,
	},
	[2] = { -- teamID
		x = 7433,
		z = 1276,
		alwaysbeacon = true,
	},
	[3] = { -- teamID
		x = 674,
		z = 6948,
		alwaysbeacon = true,
	},
}

return resources, temps, starts
