local resources = {
	{ -- center
		x = 6234, 
		z = 6076,
		feature = nil,
		radiusmult = 1.25,
	},
	{ -- center radius NE
		x = 7340, 
		z = 3462,
		feature = nil,
		points = 6,	
		radius = 300,
	},
	{ -- center radius SE
		x = 8376, 
		z = 6680,
		feature = nil,
		points = 6,	
		radius = 300,
	},
	{ -- center radius SW
		x = 4797, 
		z = 8053,
		feature = nil,
		points = 6,	
		radius = 300,
	},
	{ -- center radius NW
		x = 4752, 
		z = 4260,
		feature = nil,
		points = 6,	
		radius = 300,
	},
	{ -- plateau E
		x = 10147, 
		z = 5512,
		feature = nil,
		points = 0,
		radius = 250,
	},
	{ -- plateau W
		x = 1866, 
		z = 5436,
		feature = nil,
		points = 0,
		radius = 250,
	},
	{ -- south floor
		x = 6035, 
		z = 10878,
		feature = nil,
		radiusmult = 2,
		points = 0,
	},
	{ -- north hill
		x = 6355, 
		z = 939,
		feature = nil,
		radiusmult = 
		2,
		points = 0,
	},
}

local temps = {
	ambient = 15,
	water = 5,
}

local starts = {
	[0] = { -- teamID 1
		x = 841,
		z = 1520,
		points = 6,	
	},
	[1] = { -- teamID 2
		x = 11106,
		z = 10855,
		points = 6,	
	},
	[2] = { -- teamID 3
		x = 11022,
		z = 1413,
		alwaysbeacon = 1,
		points = 6,	
	},
	[3] = { -- teamID 4
		x = 523,
		z = 10702,
		alwaysbeacon = 1,
		points = 6,	
	},
}

return resources, temps, starts
