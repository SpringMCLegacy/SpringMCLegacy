local Warhammer = Heavy:New{
	name				= "Warhammer",
	
	customparams = {
		cockpitheight	= 9.1,
		tonnage			= 70,
    },
}

local WHM6D = Warhammer:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SBL",
		},
		[6] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant			= "WHM-6D",
		speed			= 60,
		price			= 14710,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 14},
    },
}

local WHM6K = Warhammer:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SBL",
		},
		[6] = {
			name	= "SBL",
		},
		[7] = {
			name	= "SRM6",
		},
	},
		
	customparams = {
		variant			= "WHM-6K",
		speed			= 60,
		price			= 13050,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 10},
		maxammo 		= {srm = 1},
    },
}

local WHM7S = Warhammer:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SBL",
		},
		[6] = {
			name	= "SBL",
		},
		[7] = {
			name	= "SSRM2",
		},
		[8] = {
			name	= "SSRM2",
		},
	},
		
	customparams = {
		variant			= "WHM-7S",
		speed			= 60,
		price			= 14770,
		heatlimit 		= 36,
		armor			= {type = "standard", tons = 10},
		maxammo 		= {srm = 1},
    },
}

local WHM7M = Warhammer:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MG",
		},
		[6] = {
			name	= "AMS",
		},
		[7] = {
			name	= "SRM6",
		},
	},
		
	customparams = {
		variant			= "WHM-7M",
		speed			= 60,
		price			= 14870,
		heatlimit 		= 36,
		armor			= {type = "standard", tons = 10},
		maxammo 		= {srm = 1},
    },
}

local WHM4L = Warhammer:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
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
		[6] = {
			name	= "MPL",
		},
		[7] = {
			name	= "SSRM6",
		},
	},
		
	customparams = {
		variant			= "WHM-4L",
		speed			= 60,
		price			= 18200,
		heatlimit 		= 36,
		armor			= {type = "stealth", tons = 13.5},
		maxammo 		= {srm = 1},
    },
}
		
return lowerkeys({
	["FS_Warhammer_WHM6D"] = WHM6D:New(),
	["DC_Warhammer_WHM6K"] = WHM6K:New(),
	["LA_Warhammer_WHM7S"] = WHM7S:New(),
	["FW_Warhammer_WHM7M"] = WHM7M:New(),
	["CC_Warhammer_WHM4L"] = WHM4L:New(),
})