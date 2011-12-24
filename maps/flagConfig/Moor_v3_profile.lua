local resources = {
	{
		x = 6112,
		z = 3225,
		feature = nil
	},
	{
		x = 2377,
		z = 5971,
		feature = nil
	},
}

local outposts = {
	{
		x = 5184,
		z = 6338,
		types = {"outpost_listeningpost", "outpost_c3center", "outpost_garrison"},
	},
	{
		x = 7162,
		z = 6147,
		types = {"outpost_listeningpost", "outpost_c3center", "outpost_garrison"},
	},
	{
		x = 9697,
		z = 5701,
		{"outpost_vehicledepot", "outpost_controltower", "outpost_garrison"},
	},
	{
		x = 5881,
		z = 9472,
		{"outpost_vehicledepot", "outpost_controltower", "outpost_garrison"},
	},
}

return resources, outposts
