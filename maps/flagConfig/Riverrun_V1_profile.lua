local resources = {
	{ -- center
		x = 6152,
		z = 6088,
		feature = nil,
		points = 0,
		radiusmult = 3,		
	},
	{ -- north hill
		x = 5855,
		z = 2557,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
	{ -- south hill
		x = 6454,
		z = 9670,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
	{ -- east hill
		x = 9150,
		z = 7310,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
	{ -- west hill
		x = 3192,
		z = 4902,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
	{ -- northeast hill
		x = 10668,
		z = 4147,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
	{ -- southwest hill
		x = 1592,
		z = 8111,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
}

local temps = {
	ambient = 15,
	water = 5,
	hovers = true,
}

local starts = {
	[0] = { -- teamID
		x = 1042,
		z = 1566,
	},
	[1] = { -- teamID
		x = 10763,
		z = 10353,
	},
	[2] = { -- teamID
		x = 11603,
		z = 698,
		alwaysbeacon = true,
	},
	[3] = { -- teamID
		x = 703,
		z = 11611,
		alwaysbeacon = true,
	},
	[4] = { -- teamID
		x = 787,
		z = 6119,
	},
	[5] = { -- teamID
		x = 11595,
		z = 6072,
	},
}

return resources, temps, starts
