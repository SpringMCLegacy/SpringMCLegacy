local Hunchback = Medium:New{
	name				= "Hunchback",

	leaveTracks			= true,	
	trackType			= "Hunchback",
	trackOffset			= 6,
	trackWidth			= 26,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 17.48,
		tonnage			= 50,
    },	
}

local HBK4G = Hunchback:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant			= "HBK-4G",
		speed			= 60,
		price			= 10410,
		heatlimit 		= 13,
		armor			= 10,
		maxammo 		= {ac20 = 2},
		barrelrecoildist = {[1] = 3},
    },
}

local HBK4P = Hunchback:New{
	description         = "Medium Brawler",
	weapons = {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[5] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[6] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[7] = {
			name	= "MBL",
		},
		[8] = {
			name	= "MBL",
		},
		[9] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant			= "HBK-4P",
		speed			= 60,
		price			= 11380,
		heatlimit 		= 23,
		armor			= 10,
    },
}
local HBK4J = Hunchback:New{
	description         = "Medium Missile Boat",
	weapons = {	
		[1] = {
			name	= "LRM20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "MBL",
			SlaveTo = 2,
		},
		[4] = {
			name	= "MBL",
			SlaveTo = 2,
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
		[7] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant			= "HBK-4J",
		speed			= 60,
		price			= 11430,
		heatlimit 		= 14,
		maxammo 		= {lrm = 2},
		armor			= 10,
    },
}

local HBK5S = Hunchback:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "LBX20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant			= "HBK-5S",
		speed			= 60,
		price			= 13500,
		heatlimit 		= 13,--10 double
		armor			= 11,
		jumpjets		= 4,
		maxammo 		= {ac20 = 4},
		barrelrecoildist = {[1] = 3},
		mods			= {"jumpjets", "doubleheatsinks", "endosteel", "lightengine", "case"},
    },
}

local HBK5N = Hunchback:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant			= "HBK-5N",
		speed			= 60,
		price			= 10410,
		heatlimit 		= 17,--13 double
		armor			= 11,
		maxammo 		= {ac20 = 2},
		barrelrecoildist = {[1] = 3},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({
	["FS_Hunchback_HBK4G"] = HBK4G:New(),
	["FS_Hunchback_HBK4P"] = HBK4P:New(),
	["FS_Hunchback_HBK4J"] = HBK4J:New(),
	
	["DC_Hunchback_HBK4G"] = HBK4G:New(),
	["DC_Hunchback_HBK4P"] = HBK4P:New(),
	["DC_Hunchback_HBK4J"] = HBK4J:New(),
	
	["CC_Hunchback_HBK4G"] = HBK4G:New(),
	["CC_Hunchback_HBK4P"] = HBK4P:New(),
	["CC_Hunchback_HBK4J"] = HBK4J:New(),
	
	["LA_Hunchback_HBK4P"] = HBK4P:New(),
	["LA_Hunchback_HBK5S"] = HBK5S:New(),
	["LA_Hunchback_HBK4J"] = HBK4J:New(),
	
	["FW_Hunchback_HBK4P"] = HBK4P:New(),
	["FW_Hunchback_HBK4J"] = HBK4J:New(),
	["FW_Hunchback_HBK5N"] = HBK5N:New(),
})