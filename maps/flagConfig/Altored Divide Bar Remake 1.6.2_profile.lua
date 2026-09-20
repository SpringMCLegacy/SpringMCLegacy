local resources = {
	{
		x = 1000,
		z = 3120,
		feature = nil,
		radiusmult = 0.8,
	},
	{
		x = 1575,
		z = 5140,
		feature = nil,
		radiusmult = 0.8,
	},
	{
		x = 4200,
		z = 3160,
		feature = nil,
		points = 6,
		radiusmult = 0.8,
	},
	{
		x = 3950,
		z = 5070,
		feature = nil,
		points = 6,
		radiusmult = 0.8,
	},
	{
		x = 6790,
		z = 3060,
		feature = nil,
		radiusmult = 0.8,
	},
	{
		x = 7050,
		z = 5115,
		feature = nil,
		radiusmult = 0.8,
	},
}

local temps = {
	ambient = 15,
	water = 5,
}

local starts = {
	[0] = {
		x = 866,
		z = 1171,
	},
	[1] = {
		x = 7371,
		z = 7104,
	},
	[2] = {
		x = 7329,
		z = 1062,
		alwaysbeacon = true,
	},
	[3] = {
		x = 799,
		z = 7032,
		alwaysbeacon = true,
	},
}

local camps = {
	{
		x = 3330,
		z = 1091,
	},
	{
		x = 4103,
		z = 743,
	},
	{
		x = 4933,
		z = 1217,
	},
	{
		x = 3213,
		z = 7166,
	},
	{
		x = 3935,
		z = 7511,
	},
	{
		x = 4678,
		z = 6790,
	},
	{
		x = 6212,
		z = 4005,
	},
	{
		x = 2732,
		z = 5212,
	},
}

return resources, temps, starts, camps
