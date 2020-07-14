local Hunchback = Medium:New{
	name				= "Hunchback",

	customparams = {
		cockpitheight	= 10.4,
		tonnage			= 50,
    },	
}

local HBK4G = Hunchback:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "AC20",
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
		armor			= {type = "standard", tons = 10},
		maxammo 		= {ac20 = 2},
		barrelrecoildist = {[1] = 3},
    },
}

local HBK4P = Hunchback:New{
	description         = "Medium Multirole",
	weapons = {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
		[7] = {
			name	= "MBL",
		},
		[8] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "HBK-4P",
		speed			= 60,
		price			= 11380,
		heatlimit 		= 23,
		armor			= {type = "standard", tons = 10},
    },
}

local HBK5S = Hunchback:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "LBX20",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant			= "HBK-5S",
		speed			= 60,
		price			= 13500,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 11},
		jumpjets		= 4,
		maxammo 		= {ac20 = 4},
		barrelrecoildist = {[1] = 3},
    },
}

local HBK5M = Hunchback:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "AC20",
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
		variant			= "HBK-5N",
		speed			= 60,
		price			= 10410,
		heatlimit 		= 26,
		armor			= {type = "standard", tons = 11},
		maxammo 		= {ac20 = 2},
		barrelrecoildist = {[1] = 3},
    },
}

return lowerkeys({
	["FS_Hunchback_HBK4G"] = HBK4G:New(),
	["FS_Hunchback_HBK4P"] = HBK4P:New(),
	["DC_Hunchback_HBK4G"] = HBK4G:New(),
	["CC_Hunchback_HBK4G"] = HBK4G:New(),
	["CC_Hunchback_HBK4P"] = HBK4P:New(),
	["LA_Hunchback_HBK5S"] = HBK5S:New(),
	["FW_Hunchback_HBK5M"] = HBK5M:New(),
	["FW_Hunchback_HBK4P"] = HBK4P:New(),
})