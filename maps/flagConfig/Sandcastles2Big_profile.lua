local resources = {
	{
		x = 740,
		z = 6150,
		feature = nil
	},
	{
		x = 6145,
		z = 710,
		feature = nil
	},
	{
		x = 11550,
		z = 6140,
		feature = nil
	},
	{
		x = 6159,
		z = 11550,
		feature = nil
	},
	{
		x = 6145,
		z = 6145,
		feature = nil
	},
}

local temps = {
	ambient = 40,
	water = 30,
}

local starts = {
	[0] = { -- teamID 1
		x = 681,
		z = 744,
	},
	[1] = { -- teamID 2
		x = 11475,
		z = 11533,
	},
	[2] = { -- teamID 3
		x = 11561,
		z = 710,
	},
	[3] = { -- teamID 4
		x = 760,
		z = 11647,
	},
}

return resources, temps, starts

