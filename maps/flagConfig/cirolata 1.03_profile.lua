local resources = {
	{
		x = 4087,
		z = 4094,
		feature = nil,
		radiusmult = 1.5,
		points = 0,
	},
	{
		x = 3507,
		z = 6663,
		feature = nil,
	},
	{
		x = 6688,
		z = 4680,
		feature = nil,
		
	},
	{
		x = 1492,
		z = 3498,
		feature = nil,

	},
	{
		x = 4685,
		z = 1482,
		feature = nil
	},
	{
		x = 4221,
		z = 5682,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 5697,
		z = 3967,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 3963,
		z = 2511,
		feature = nil,
		radius = 200,
		points = 1,
	},
	{
		x = 2516,
		z = 4213,
		feature = nil,
		radius = 200,
		points = 1,		
	},
}

local temps = {
	ambient = 26,
	water = 19,
	hovers = false,
}

local starts = {
	[0] = {
		x = 1633,
		z = 6086,
		alwaysbeacon = true,
	},
	[1] = {
		x = 6591,
		z = 2070,
		alwaysbeacon = true,
	},
	[2] = {
		x = 6089,
		z = 6562,
		alwaysbeacon = true,
	},
	[3] = {
		x = 2111,
		z = 1603,
		alwaysbeacon = true,
	},
}

return resources, temps, starts
