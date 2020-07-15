local Sentinel = Medium:New{
	name				= "Sentinel",
	
	customparams = {
		cockpitheight	= 4.3,
		tonnage			= 40,
    },
}

local STN3L = Sentinel:New{
	description         = "Medium Ranged",
	weapons = {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "SSRM2",
			OnlyTargetCategory = "ground",
		},
	},
		
    customparams = {
		variant			= "STN-3L",
		speed			= 90,
		price			= 7170,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5.5},
		maxammo 		= {ac5 = 1, srm = 1},
		barrelrecoildist = {[1] = 4},
    },
}

local STN3M = Sentinel:New{
	description         = "Medium Ranged",
	weapons = {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "SRM2",
		},
	},
		
    customparams = {
		variant			= "STN-3M",
		speed			= 90,
		price			= 7580,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5.5},
		maxammo 		= {ac5 = 1, srm = 1},
		barrelrecoildist = {[1] = 4},
    },
}

local STN4D = Sentinel:New{
	description         = "Medium Multirole",
	weapons = {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "ERMBL",
		},
	},
		
    customparams = {
		variant			= "STN-4D",
		speed			= 90,
		price			= 13790, --11790
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 7},
		maxammo 		= {ac5 = 2},
    },
}

return lowerkeys({
	--["LA_Sentinel_STN3L"] = STN3L:New(),
	--["DC_Sentinel_STN3M"] = STN3M:New(),
	--["FW_Sentinel_STN3M"] = STN3M:New(),
	--["FS_Sentinel_STN4D"] = STN4D:New(),
})