local resources = {
	{
		x =1870,
		z =2250,
		feature = nil
	},
	{
		x =8400,
		z =2100,
		feature = nil
	},
	{
		x =2750,
		z =5580,
		feature = nil
	},
	{
		x =7625,
		z =5500,
		feature = nil
	},
	{
		x =5220,
		z =4500,
		feature = nil
	},
	{
		x =5200,
		z =630,
		feature = nil
	},
	{
		x =5200,
		z =2830,
		feature = nil
	},
}

local temps = {
	ambient = 50,
	water = 35,
}

local starts = {
	[0] = { -- teamID
		x = 435,
		z = 375,
	},
	[1] = { -- teamID
		x = 9800,
		z = 460,
	},
	[2] = { -- teamID
		x = 385,
		z = 5450,
	},
	[3] = { -- teamID
		x = 9815,
		z = 5750,
	},
}

return resources, temps, starts
