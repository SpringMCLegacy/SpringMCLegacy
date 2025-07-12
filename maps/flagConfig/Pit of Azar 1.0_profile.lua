local resources = {
	{ --middle volcano
		x = 8150,
		z = 8150,
		feature = nil,
		radiusmult = 2.8,
		points = 12,
		gaiaoutposts = {
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
			"outpost_artillery",
		},
	},
	{ -- inner rim 1
		x = 2913,
		z = 3349,
		feature = nil,
	},
	{ -- inner rim 2
		x = 8005,
		z = 3058,
		feature = nil,
	},
	{ -- inner rim 3
		x = 12482,
		z = 4948,
		feature = nil,
	},
	{ -- inner rim 4
		x = 13541,
		z = 12798,
		feature = nil,
	},
	{ -- inner rim 5
		x = 8239,
		z = 13287,
		feature = nil,
	},
	{ -- inner rim 6
		x = 3429,
		z = 11326,
		feature = nil,
	},
	{ -- floor west
		x = 3982,
		z = 7517,
		feature = nil,
		radiusmult = 2,
		points = 6,	
	},
	{ -- floor east
		x = 12431,
		z = 8754,
		feature = nil,
		radiusmult = 2,
		points = 6,	
	},
	{ -- floor southeast small
		x = 9815,
		z = 10345,
		feature = nil,
		points = 0,	
	},
	{ -- floor northwest small
		x = 6364,
		z = 6183,
		feature = nil,
		points = 0,
	},	
	{ -- south bottom vantage
		x = 6113,
		z = 10790,
		feature = nil,
		radius = 300,
	},
	{ -- north bottom vantage
		x = 10216,
		z = 5521,
		feature = nil,
		radius = 300,
	},
	{ -- eastern upper rim
		x = 14791,
		z = 6744,
		feature = nil,
	},
	{ -- western upper rim
		x = 1470,
		z = 9577,
		feature = nil,	
	},
}

local temps = {
	ambient = 21,
	water = 12,
}

local starts = {
	[0] = { -- teamID
		x = 1595,
		z = 1845,
	},
	[1] = { -- teamID
		x = 14553,
		z = 14751,
	},
	[2] = { -- teamID
		x = 1881,
		z = 12974,
		alwaysbeacon = true,
	},
	[3] = { -- teamID
		x = 14404,
		z = 3406,
		alwaysbeacon = true,
	},
	[4] = { -- teamID
		x = 8713,
		z = 15567,
		alwaysbeacon = true,
	},
	[5] = { -- teamID
		x = 7526,
		z = 783,
		alwaysbeacon = true,
	},
}

return resources, temps, starts
