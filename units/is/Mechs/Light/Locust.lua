local Locust = Light:New{
	name			= "Locust",
	customparams = {
		cockpitheight	= 36,
		tonnage 		= 20,
    },
}

local LCT3M = Locust:New{
	description         = "Light Scout/Support",
	weapons = {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "SBL",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "SBL",
		},
		[5] = {
			name	= "SBL",
		},
		[6] = {
			name	= "AMS",
		},
	},
		
	customparams = {
		variant         = "LCT3M",
		speed			= 120,
		price			= 5220,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 3},
    },
}

local LCT5M = Locust:New{
	description         = "Light Scout",
	weapons	= {	
		[1] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
		[5] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
	customparams = {
		variant         = "LCT5M",
		speed			= 180,
		price			= 7190,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4},
    },
}

local LCT3D = Locust:New{
	description         = "Light LRM Support",
	weapons	= {	
		[1] = {
			name	= "LRM5",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "LRM5",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
	customparams = {
		variant         = "LCT-3D",
		speed			= 120,
		price			= 4360,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 2.5},
		maxammo 		= {lrm = 1},
    },
}

local LCT3S = Locust:New{
	description         = "Light Scout",
	weapons	= {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "SSRM2",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "SSRM2",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
	customparams = {
		variant         = "LCT-3S",
		speed			= 120,
		price			= 4830,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 2.5},
		maxammo 		= {srm = 1},
    },
}

local LCT1L = Locust:New{
	description         = "Light Scout",
	weapons	= {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
		[5] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
	customparams = {
		variant         = "LCT-1L",
		speed			= 120,
		price			= 4740,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4},
		masc			= true,
    },
}

return lowerkeys({
	["FW_Locust_LCT3M"] = LCT3M:New(),
	["FW_Locust_LCT5M"] = LCT5M:New(),
	["FS_Locust_LCT3D"] = LCT3D:New(),
	["LA_Locust_LCT3S"] = LCT3S:New(),
	["CC_Locust_LCT1L"] = LCT1L:New(),
})