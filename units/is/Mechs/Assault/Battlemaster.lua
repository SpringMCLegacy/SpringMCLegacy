local Battlemaster = Assault:New{
	name				= "Battlemaster",
    customparams = {
		cockpitheight	= 6.1,
		tonnage			= 85,
    },
}

local BLRK3 = Battlemaster:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERLBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "ERLBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "SSRM6",
		},
	},
    customparams = {
		variant			= "BLR-K3",
		speed			= 60,
		price			= 18510,
		heatlimit 		= 24,--18 double
		armor			= 16,
		maxammo 		= {srm = 1},
		mods			= {"doubleheatsinks"},
    },
}

local BLR1G = Battlemaster:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "SRM6",
		},
		[9] = {
			name	= "MG",
		},
		[10] = {
			name	= "MG",
		},
	},
    customparams = {
		variant			= "BLR-1G",
		speed			= 60,
		price			= 15190,
		heatlimit 		= 36,
		armor			= 14.5,
		maxammo 		= {srm = 1},
    },
}

local BLR3M = Battlemaster:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "SRM6",
		},
		[9] = {
			name	= "MG",
		},
	},
    customparams = {
		variant			= "BLR-3M",
		speed			= 60,
		price			= 16790,
		heatlimit 		= 24,--18 double
		armor			= 14.5,
		maxammo 		= {srm = 1},
		mods			= {"doubleheatsinks"},
    },
}

local BLR5M = Battlemaster:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "LightGauss",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "BLR-5M",
		speed			= 60,
		price			= 17660,
		heatlimit 		= 19,--14 double
		armor			= 14.5,
		maxammo 		= {ltgauss = 1},
		barrelrecoildist = {[1] = 3},
		mods			= {"doubleheatsinks"},
    },
}

local BLR4S = Battlemaster:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "SRM6",
		},
		[9] = {
			name	= "SPL",
		},
		[10] = {
			name	= "SPL",
		},
	},
    customparams = {
		variant			= "BLR-4S",
		speed			= 60,
		price			= 20180,
		heatlimit 		= 17,--13 double
		armor			= 13.5,
		maxammo 		= {gauss = 3, srm = 2},
		barrelrecoildist = {[1] = 3},
		mods			= {"ferrofibrousarmour", "artemissrm", "doubleheatsinks"},
    },
}

return lowerkeys({
	--CC_Battlemaster_BLR1G = BLR1G:New(),
	--DC_Battlemaster_BLRK3 = BLRK3:New(),
	FW_Battlemaster_BLR3M = BLR3M:New(),
	FW_Battlemaster_BLR5M = BLR5M:New(),
	LA_Battlemaster_BLR4S = BLR4S:New(),
})