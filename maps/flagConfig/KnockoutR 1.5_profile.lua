local resources = {
	{
		x = 4595, -- center
		z = 4297,
		feature = nil
	},
	{
		x = 4633, -- top
		z = 1727,
		feature = nil
	},
	{
		x = 7454, -- right
		z = 4606,
		feature = nil
	},
	{
		x = 4644, -- bottom
		z = 7354,
		feature = nil
	},
	{
		x = 1848, -- left
		z = 4587,
		feature = nil
	},
}

local temps = {
	ambient = 20,
	water = 15,
}

local starts = {
	[0] = { -- teamID 1
		x = 660,
		z = 8572,
	},
	[1] = { -- teamID 2
		x = 8592,
		z = 559,
	},
	[2] = { -- teamID 3
		x = 577,
		z = 624,
	},
	[3] = { -- teamID 4
		x = 8523,
		z = 8477,
	},
}

return resources, temps, starts
