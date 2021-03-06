local Starslayer = Medium:New{
	name				= "Starslayer",
	
	customparams = {
		cockpitheight	= 9.6,
		tonnage			= 40,
    },
}

local STY3C = Starslayer:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "LBL",
		},
		[2] = {
			name	= "LBL",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "SRM4",
		},
	},

	customparams = {
		variant			= "STY-3C",
		speed			= 80,
		price			= 15080,
		heatlimit 		= 15,--11 double
		armor			= 9.5,
		jumpjets		= 5,
		maxammo 		= {srm = 1},
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

local STY3D = Starslayer:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "LBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
	},

	customparams = {
		variant			= "STY-3D",
		speed			= 80,
		price			= 15930,
		heatlimit 		= 16,--12 single
		armor			= 9.5,
		jumpjets		= 5,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

return lowerkeys({ 
	--["FS_Starslayer_STY3D"] = STY3D:New(),
	["LA_Starslayer_STY3C"] = STY3C:New(),
})