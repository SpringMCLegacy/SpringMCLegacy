local Dervish = Medium:New{
	name				= "Dervish",

	customparams = {
		cockpitheight	= 9.9,
		tonnage			= 55,
    },
}
	
local DV6M = Dervish:New{
	description         = "Medium Missile Support",
	weapons = {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "LRM10",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SRM2",
		},
		[6] = {
			name	= "SRM2",
		},
	},
		
	customparams = {
		variant			= "DV-6M",
		speed			= 80,
		price			= 11460,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 7.5},
		jumpjets		= 5,
		maxammo 		= {srm = 2, lrm = 2},
    },
}

local DV8D = Dervish:New{
	description         = "Medium Missile Support",
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
		armor			= {type = "standard", tons = 10.5},
		jumpjets		= 5,
		maxammo 		= {lrm = 4},
    },
}

return lowerkeys({ 
	["FW_Dervish_DV6M"] = DV6M:New(),
	["FS_Dervish_DV8D"] = DV8D:New(),
})