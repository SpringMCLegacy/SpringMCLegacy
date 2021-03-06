local Hellspawn = Medium:New{
	name				= "Hellspawn",

	customparams = {
		cockpitheight	= 8.5,
		tonnage			= 45,
    },
}
	
local HSN7D = Hellspawn:New{
	description         = "Medium Skirmisher",
	weapons = {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "LRM10",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant			= "HSN-7D",
		speed			= 90,
		price			= 12200,
		heatlimit 		= 13,--10 double
		armor			= 6.5,
		jumpjets		= 6,
		maxammo 		= {lrm = 2},
		ecm				= true,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["FS_Hellspawn_HSN7D"] = HSN7D:New(),
})