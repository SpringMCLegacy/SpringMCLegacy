local resources = {
	{ -- north
		x =6899,
		z =900,
		feature = nil,
		points = 6,
		radiusmult = 1.5,
	},
	{
		x =11281,
		z =1402,
		feature = nil,
	},
	{
		x =2668,
		z =10812,
		feature = nil,
	},
	{ --south hill
		x =5599,
		z =8676,
		feature = nil,
		points = 6,
		radiusmult = 2,
	},
	{
		x =3685,
		z =4064,
		feature = nil,
	},
	{
		x =8024,
		z =6313,
		feature = nil,
	},
}

local temps = {
	ambient = 24,
	water = 15,
}

local starts = {
	[0] = { -- teamID
		x = 759,
		z = 578,
	},
	[1] = { -- teamID
		x = 11017,
		z = 11443,
	},
}

return resources, temps, starts
