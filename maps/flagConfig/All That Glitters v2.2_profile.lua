local resources = {
	{ -- west
		x = 864,
		z = 5529,
		feature = nil,
		points = 6,
	}, 	
	{ -- east
		x = 5549,
		z = 4182,
		feature = nil,
		points = 6,
	},
	{ -- south mid
		x = 2900,
		z = 7967,
		feature = nil,
	},
	{ -- north mid
		x = 3059,
		z = 2401,
		feature = nil,
	},
	{ -- big middle
		x = 3197,
		z = 4753,
		feature = nil,
		points = 0,
		radiusmult = 1.5,
	},
}

local temps = {
	ambient = 10,
	water = 1,
}

local starts = {
	[0] = { -- teamID 1
		x = 1073,
		z = 937,
	},
	[1] = { -- teamID 2
		x = 5171,
		z = 9164,
	},
	[2] = { -- teamID 2
		x = 5086,
		z = 805,
		alwaysbeacon = true,
	},
	[3] = { -- teamID 2
		x = 720,
		z = 9556,
		alwaysbeacon = true,
	},
}

return resources, temps, starts
