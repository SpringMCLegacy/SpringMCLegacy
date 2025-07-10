local resources = {
	{ -- sw corner
		x = 801,
		z = 7443,
		feature = nil,
		points = 0,
		radiusmult = 1.7,
	}, 	
	{ -- ne corner
		x = 9411,
		z = 867,
		feature = nil,
		points = 0,
		radiusmult = 1.7,
	},
	{ -- w bridge
		x = 2707,
		z = 5374,
		feature = nil,
		points = 0,
		radiusmult = 0.5,
	},
	{ -- e bridge
		x = 7568,
		z = 3000,
		feature = nil,
		points = 0,
		radiusmult = 0.5,
	},
	{ -- nw basin
		x = 3038,
		z = 2021,
		feature = nil,
		points = 6,
		radiusmult = 1.7,
	},
	{ -- se basin
		x = 7667,
		z = 6182,
		feature = nil,
		points = 6,
		radiusmult = 1.7,
	},
	{ -- sw hill
		x = 3401,
		z = 6699,
		feature = nil,
		points = 0,
	},
	{ -- ne hill
		x = 6943,
		z = 1653,
		feature = nil,
		points = 0,
	},
	{ -- n shore
		x = 5273,
		z = 3234,
		feature = nil,
		points = 0,
		radiusmult = 0.5
	},
	{ -- s shore
		x = 5167,
		z = 4596,
		feature = nil,
		points = 0,
		radiusmult = 0.5
	},	
	{ -- nw bridge shore
		x = 2591,
		z = 3905,
		feature = nil,
		points = 0,
	},
	{ -- sw  bridge shore
		x = 1742,
		z = 6419,
		feature = nil,
		points = 0,
	},		
	{ -- ne bridge shore
		x = 8571,
		z = 1893,
		feature = nil,
		points = 0,
	},	
	{ -- se bridge shore
		x = 7141,
		z = 4283,
		feature = nil,
		points = 0,
	},
	{ -- s plateau
		x = 5101,
		z = 5343,
		feature = nil,
		points = 0,
		radiusmult = 0.5,
	},		
	{ -- n plateau
		x = 5664,
		z = 2091,
		feature = nil,
		points = 0,
		radiusmult = 0.5,
	},	
	{ -- ne smol single
		x = 9815,
		z = 2455,
		feature = nil,
		points = 1,
		radiusmult = 0.5,
	},	
	{ -- sw smol single
		x = 396,
		z = 5616,
		feature = nil,
		points = 1,
		radiusmult = 0.5,
	},	

}

local temps = {
	ambient = 17,
	water = 9,
	hovers = true,
}

local starts = {
	[0] = { -- teamID 1
		x = 626,
		z = 566,
		alwaysbeacon = 1,
	},
	[1] = { -- teamID 2
		x = 9669,
		z = 7391,
		alwaysbeacon = 1,
	},
	[2] = { -- teamID 3
		x = 5293,
		z = 7241,
		alwaysbeacon = 1,
	},
	[3] = { -- teamID 4
		x = 9686,
		z = 5392,
		alwaysbeacon = 1,
	},
	[4] = { -- teamID 5
		x = 452,
		z = 2206,
		alwaysbeacon = 1,
	},
	[5] = { -- teamID 6
		x = 5275,
		z = 506,
		alwaysbeacon = 1,
	},
}

return resources, temps, starts
