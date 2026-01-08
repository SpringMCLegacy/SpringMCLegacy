local resources = {
	{ -- king of the hill
		x = 6152,
		z = 5647,
		feature = nil,
		points = 6,
		radiusmult = 2.3,		
	},
	--[[{ -- top west
		x = 4293,
		z = 5758,
		feature = nil,
		points = 6,
	},
	{ -- top northeast
		x = 6885,
		z = 4096,
		feature = nil,
		points = 6,
	},
	{ -- top southeast
		x = 7042,
		z = 7100,
		feature = nil,
		points = 6,
	},]]
	{ -- mid north
		x = 5545,
		z = 2355,
		feature = nil,
		points = 0,
	},
	{ -- mid northeast
		x = 9128,
		z = 4306,
		feature = nil,
		points = 0,
	},
	{ -- mid southeast
		x = 8560,
		z = 8255,
		feature = nil,
		points = 0,
	},
	{ -- mid southwest
		x = 4546,
		z = 8860,
		feature = nil,
		points = 0,
	},
	{ -- mid west
		x = 2748,
		z = 5128,
		feature = nil,
		points = 0,
	},
}

local temps = {
	ambient = 15,
	water = 5,
	hovers = false,
}

local starts = {
	[0] = { -- teamID
		x = 1671,
		z = 3009,
		alwaysbeacon = true,
	},
	[1] = { -- teamID
		x = 10996,
		z = 6688,
		alwaysbeacon = true,
	},
	[2] = { -- teamID
		x = 4472,
		z = 11127,
		alwaysbeacon = true,
	},
	[3] = { -- teamID
		x = 9996,
		z = 2070,
		alwaysbeacon = true,
	},
	[4] = { -- teamID
		x = 1046,
		z = 7736,
		alwaysbeacon = true,
	},
	[5] = { -- teamID
		x = 8985,
		z = 10776,
		alwaysbeacon = true,
	},
	[6] = { -- teamID
		x = 5247,
		z = 1029,
		alwaysbeacon = true,
	},
}

return resources, temps, starts
