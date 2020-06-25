local Starslayer = Medium:New{
	name				= "Starslayer",
	
	customparams = {
		cockpitheight	= 18,
		tonnage			= 40,
    },
}

local STY3C = Starslayer:New{
	description         = "Medium Striker",
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
		heatlimit 		= 22,
		armor			= {type = "ferro", tons = 9.5},
		jumpjets		= 5,
		maxammo 		= {srm = 1},
    },
}

local STY3D = Starslayer:New{
	description         = "Medium Sniper",
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
		heatlimit 		= 24,
		armor			= {type = "ferro", tons = 9.5},
		jumpjets		= 5,
    },
}

return lowerkeys({ 
	["FS_Starslayer_STY3D"] = STY3D:New(),
	["LA_Starslayer_STY3C"] = STY3C:New(),
})