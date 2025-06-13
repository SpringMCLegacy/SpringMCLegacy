local resources = {
	{
		x = 1505,
		z = 5575,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 4133,
		z = 5922,
		feature = nil,
	},
	{
		x = 6172,
		z = 5000,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 2035,
		z = 2221,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 4050,
		z = 1258,
		feature = nil
	},
	{
		x = 6686,
		z = 1600,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 2411,
		z = 4107,
		feature = nil
	},
	{
		x = 5815,
		z = 3136,
		feature = nil
	},
	{
		x = 4061,
		z = 3597,
		feature = nil,
		radiusmult = 1.5,
		points = 12,		
	},
}

local temps = {
	ambient = 20,
	water = 15,
	hovers = false,
}

local starts = {
	[0] = { -- teamID 1
		x = 699,
		z = 561,
	},
	[1] = { -- teamID 2
		x = 7493,
		z = 6613,
	},
	[2] = { -- teamID 1
		x = 458,
		z = 6400,
	},
	[3] = { -- teamID 2
		x = 7741,
		z = 772,
	},
}

return resources, temps, starts
