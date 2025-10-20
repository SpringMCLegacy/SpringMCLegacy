local resources = {
	{ -- Calderra
		x = 7190,
		z = 7032,
		feature = nil,
		points = 0,
		radius = 800,
	},
	--[[{ -- N
		x = 7181,
		z = 3998,
		points = 0,
		feature = nil,
		radius = 800,
	},]]
	{ -- NE
		x = 9255,
		z = 5003,
		points = 3,
		feature = nil,
	},
	--[[{ -- E
		x = 10315,
		z = 7218,
		points = 0,
		feature = nil,
	},]]
	{ -- SE
		x = 9508,
		z = 9325,
		points = 3,
		feature = nil,
	},
	--[[{ -- S
		x = 7403,
		z = 10276,
		points = 0,
		feature = nil,
	},]]
	{ -- SW
		x = 5348,
		z = 9603,
		points = 3,
		feature = nil,
	},
	--[[{ -- W
		x = 4323,
		z = 7089,
		points = 0,
		feature = nil,
	},]]
	{ -- NW
		x = 4923,
		z = 5092,
		points = 3,
		feature = nil,
	},
}

local temps = {
	ambient = 18,
	water = 8,
}

local starts = {
	[0] = { -- teamID
		x = 2181,
		z = 5282,
		--alwaysbeacon = true,
	},
	[1] = { -- teamID
		x = 12341,
		z = 9037,
		--alwaysbeacon = true,
	},
	[2] = { -- teamID
		x = 9143,
		z = 2214,
		--alwaysbeacon = true,
	},
	[3] = { -- teamID
		x = 5311,
		z = 12077,
		--alwaysbeacon = true,
	},
	[4] = { -- teamID
		x = 4896,
		z = 2369,
		--alwaysbeacon = true,
	},
	[5] = { -- teamID
		x = 9524,
		z = 12084,
		--alwaysbeacon = true,
	},
	[6] = { -- teamID
		x = 12098,
		z = 5285,
		--alwaysbeacon = true,
	},
	[7] = { -- teamID
		x = 2339,
		z = 9333,
		--alwaysbeacon = true,
	},
	
	
	
}

return resources, temps, starts
