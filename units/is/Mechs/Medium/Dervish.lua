local Dervish = Medium:New{
	name				= "Dervish",

	customparams = {
		cockpitheight	= 10.2,
		tonnage			= 55,
    },
}
	
local DV6M = Dervish:New{
	description         = "Medium Missile Boat",
	weapons = {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "LRM10",
		},
		[3] = {
			name	= "SRM2",
		},
		[4] = {
			name	= "SRM2",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "DV-6M",
		speed			= 80,
		price			= 11460,
		heatlimit 		= 10,
		armor			= 7.5,
		jumpjets		= 5,
		maxammo 		= {srm = 2, lrm = 2},
    },
}

local DV7D = Dervish:New{
	description         = "Medium Missile Boat",
	weapons = {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "LRM10",
		},
		[3] = {
			name	= "SSRM2",
		},
		[4] = {
			name	= "SSRM2",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "DV-7D",
		speed			= 80,
		price			= 14120,
		heatlimit 		= 20,
		armor			= 8,
		jumpjets		= 5,
		maxammo 		= {srm = 2, lrm = 2},
		mods			= {"ferrofibrousarmour"},
    },
}

local DV8D = Dervish:New{
	description         = "Medium Missile Boat",
	weapons = {	
		[1] = {
			name	= "ALRM15",
		},
		[2] = {
			name	= "ALRM15",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
		[6] = {
			name	= "ERMBL",
		},
	},
		
    customparams = {
		variant			= "DV-8D",
		speed			= 80,
		price			= 17650,
		heatlimit 		= 20,
		armor			= 10.5,
		jumpjets		= 5,
		maxammo 		= {lrm = 4},
		mods			= {"artemislrm"},
    },
}

return lowerkeys({ 
	["FW_Dervish_DV6M"] = DV6M:New(),
	--["FS_Dervish_DV8D"] = DV8D:New(),
	["FS_Dervish_DV7D"] = DV7D:New(),
})