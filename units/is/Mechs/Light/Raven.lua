local Raven = Light:New{
	name				= "Raven",

	customparams = {
		cockpitheight	= 2.1,
		tonnage			= 35,
    },
}

local RVN3L = Raven:New{
	description         = "Light Scout",
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
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "TAG",
		},
	},
		
	customparams = {
		variant         = "RVN-3L",
		speed			= 90,
		price			= 7080,
		heatlimit 		= 11,
		armor			= 4.5,
		bap				= true,
		ecm				= true,
		maxammo 		= {narc = 2, srm = 1},
		mods 			= {"ferrofibrousarmour"},
    },
}

local RVN4L = Raven:New{
	description         = "Light Scout",
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
		},
		[5] = {
			name	= "TAG",
		},
	},

	customparams = {
		variant         = "RVN-4L",
		speed			= 90,
		price			= 8730,
		heatlimit 		= 13,--10 double
		armor			= 6,
		bap				= true,
		ecm				= true,
		maxammo 		= {narc = 1, srm = 1},
		mods			= {"doubleheatsinks"},--stealtharmour
    },
}

local RVN3M = Raven:New{
	description         = "Light Missile Boat",
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
		heatlimit 		= 11,
		armor			= 3.5,
		maxammo 		= {narc = 2, lrm = 2},
		mods 			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["DC_Raven_RVN3L"] = RVN3L:New(),
	["CC_Raven_RVN3L"] = RVN3L:New(),
	["FW_Raven_RVN3M"] = RVN3M:New(),
	["FW_Raven_RVN3L"] = RVN3L:New(),
})