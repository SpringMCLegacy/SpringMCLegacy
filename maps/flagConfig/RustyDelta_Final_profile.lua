local resources = {
	{
		x = 3821,
		z = 3842,
		feature = nil
	},
	{
		x = 6399,
		z = 3842,
		feature = nil
	},
}
	
local outposts = {
	{
		x = 5156,
		z = 2053,
		types = {"outpost_listeningpost", "outpost_garrison", "outpost_c3center"},
	},
		{
		x = 5096,
		z = 301,
		types = {"beacon", "outpost_listeningpost", "outpost_garrison"},
	},
	{
		x = 2000,
		z = 1200,
		types = {"outpost_vehicledepot", "outpost_garrison", "outpost_controltower"},
	},
	{
		x = 8200,
		z = 1200,
		types = {"outpost_vehicledepot", "outpost_garrison", "outpost_controltower"},
	},
}

return resources, outposts
