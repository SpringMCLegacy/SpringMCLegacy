local Raven = Light:New{
	name				= "Raven",

	leaveTracks			= true,	
	trackType			= "Raven",
	trackOffset			= 6,
	trackWidth			= 30,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 5.40,
		tonnage			= 35,
    },
}

local RVN3L = Raven:New{
	description         = "Light EWAR Support",
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "NARC",
		},
		[5] = {
			name	= "TAG",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant         = "RVN-3L",
		speed			= 90,
		price			= 7080,
		heatlimit 		= 11,--11 Single
		armor			= 4.5,
		bap				= true,
		ecm				= true,
		maxammo 		= {narc = 2, srm = 1},
		mods 			= {"beagle", "guardian", "ferrofibrousarmour", "xlengine", "case"},
    },
}

local RVN4L = Raven:New{
	description         = "Light EWAR Support",
	weapons = {	
		[1] = {
			name	= "ERMBL",
		},
		[2] = {
			name	= "ERMBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "NARC",
		},
		[5] = {
			name	= "TAG",
			OnlyTargetCategory = "ground",
		},
	},

	customparams = {
		variant         = "RVN-4L",
		speed			= 90,
		price			= 8730,
		heatlimit 		= 10,--10 double
		armor			= 6,
		bap				= true,
		ecm				= true,
		maxammo 		= {narc = 1, srm = 1},
		mods			= {"beagle", "guardian", "doubleheatsinks", "stealtharmour", "xlengine"},
    },
}

local RVN3M = Raven:New{
	description         = "Light Missile Scout",
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
		price			= 6390,
		heatlimit 		= 10,--10 single
		armor			= 3.5,
		maxammo 		= {narc = 2, lrm = 2},
		mods 			= {"ferrofibrousarmour", "xlengine", "case"},
    },
}

return lowerkeys({
	["DC_Raven_RVN3L"] = RVN3L:New(),
	["CC_Raven_RVN3L"] = RVN3L:New(),
	["CC_Raven_RVN4L"] = RVN4L:New(),
	["FW_Raven_RVN3L"] = RVN3L:New(),
	["FW_Raven_RVN3M"] = RVN3M:New(),
})