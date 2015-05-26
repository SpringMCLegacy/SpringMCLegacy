local Raven = Light:New{
	name				= "Raven",

	customparams = {
		tonnage		= 35,
    },
}

local RVN3L = Raven:New{
	description         = "Light EWAR",
	weapons	= {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "NARC",
			OnlyTargetCategory = "narctag",
		},
		[4] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "TAG",
			OnlyTargetCategory = "narctag",
		},
	},
		
	customparams = {
		variant         = "RVN-3L",
		speed			= 90,
		price			= 16000,
		heatlimit 		= 11,
		armor			= {type = "ferro", tons = 4.5},
		bap				= true,
		ecm				= true,
		maxammo 		= {narc = 12, srm = 90},
    },
}

local RVN4L = Raven:New{
	description         = "Light EWAR",
	weapons = {	
		[1] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "NARC",
		},
		[4] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "TAG",
		},
	},

	customparams = {
		variant         = "RVN-4L",
		speed			= 90,
		price			= 18000,
		heatlimit 		= 20,
		armor			= {type = "stealth", tons = 6},
		bap				= true,
		ecm				= true,
		maxammo 		= {narc = 12, srm = 90},
    },
}

local RVN3M = Raven:New{
	description         = "Light LRM Support",
	weapons	= {	
		[1] = {
			name	= "LRM15",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "SBL",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "SPL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "NARC",
			OnlyTargetCategory = "narctag",
		},
	},
		
	customparams = {
		variant         = "RVN-3M",
		speed			= 90,
		price			= 16000,
		heatlimit 		= 11,
		armor			= {type = "ferro", tons = 3.5},
		maxammo 		= {narc = 12, lrm = 240},
    },
}

return lowerkeys({
	["DC_Raven_RVN3L"] = RVN3L:New(),
	["CC_Raven_RVN4L"] = RVN4L:New(),
	["FW_Raven_RVN3M"] = RVN3M:New(),
})