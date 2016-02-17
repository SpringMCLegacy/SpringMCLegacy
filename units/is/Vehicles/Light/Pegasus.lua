local Pegasus = Hover:New{
	name              	= "Pegasus",
	description			= "Light Harasser",
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MBL",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 120,
		price			= 6060,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5},
		maxammo 		= {srm = 2},
		squadsize 		= 2,
    },
}

local PegasusK = Pegasus:New{
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MPL",
			maxAngleDif = 30,
		},
		[4] = {
			name	= "TAG",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "(Kurita)",
		speed			= 140,
		price			= 8060,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5},
		maxammo 		= {srm = 2},
		squadsize 		= 1,
		replaces		= "dc_pegasus",
    },
}

return lowerkeys({
	["CC_Pegasus"] = Pegasus:New(),
	["DC_Pegasus"] = Pegasus:New(),
	["DC_PegasusK"] = PegasusK:New(),
	["FS_Pegasus"] = Pegasus:New(),
	["FW_Pegasus"] = Pegasus:New(),
	["LA_Pegasus"] = Pegasus:New(),
})