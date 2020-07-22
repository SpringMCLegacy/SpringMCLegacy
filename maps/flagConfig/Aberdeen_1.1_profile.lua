local resources = {
	{
		x = 4050,
		z = 3650,
		feature = nil
	},
	{
		x = 810,
		z = 3480,
		feature = nil
	},
	{
		x = 7200,
		z = 1170,
		feature = nil
	},
	{
		x = 5300,
		z = 6750,
		feature = nil
	},
}

local temps = {
	ambient = 30,
	water = 20,
	hovers = true,
}

local starts = {
	[0] = { -- teamID
		x = 1900,
		z = 315,
	},
	[1] = { -- teamID
		x = 2815,
		z = 7710,
	},
	[2] = { -- teamID
		x = 7550,
		z = 3860,
	},
}

return resources, temps, starts
