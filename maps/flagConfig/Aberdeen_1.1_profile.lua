local resources = {
	{ -- center
		x = 4050,
		z = 3650,
		feature = nil,
		radiusmult = 1.5,
		points = 0,
	},
	{ -- west
		x = 810,
		z = 3480,
		feature = nil,
		points = 6,
	},
	{ -- northeast
		x = 7200,
		z = 1170,
		feature = nil,
		points = 6,
	},
	{ --southeast
		x = 5300,
		z = 6750,
		feature = nil,
		points = 6,
	},
}

local temps = {
	ambient = 21,
	water = 12,
	hovers = true,
}

local starts = {
	[0] = { -- teamID
		x = 1900,
		z = 465,
	},
	[1] = { -- teamID
		x = 2815,
		z = 7710,
	},
	[2] = { -- teamID
		x = 7550,
		z = 3860,
	},
}

return resources, temps, starts
