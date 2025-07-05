local Cicada = Medium:New{
	name				= "Cicada",
	
	leaveTracks			= true,	
	trackType			= "Cicada",
	trackOffset			= 6,
	trackWidth			= 30,
	trackStretch 		= 2,
	customparams = {
		cockpitheight	= 3,
		tonnage			= 40,
    },
}

local CDA3C = Cicada:New{
	description         = "Medium Fast Sniper",
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MG",
		},
	},

	customparams = {
		variant			= "CDA-3M",
		speed			= 110,
		price			= 6260,
		heatlimit 		= 10,--10 single
		armor			= 4,
    },
}

local CDA3M = Cicada:New{
	description         = "Medium Scout",
	weapons	= {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "SPL",
		},
	},

	customparams = {
		variant			= "CDA-3M",
		speed			= 120,
		price			= 8120,
		heatlimit 		= 10,--10 dsingle
		armor			= 4,
		maxammo 		= {ac5 = 1},
		barrelrecoildist = {[1] = 3},
		mods			= {"xlengine", "case"},
    },
}

local CDA3F = Cicada:New{
	description         = "Medium Scout",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},

	customparams = {
		variant			= "CDA-3F",
		speed			= 120,
		price			= 13290,
		heatlimit 		= 10,--10 double
		armor			= 6.5,
		jumpjets		= 8,
		mods			= {"jumpjets", "ferrofibrousarmour", "doubleheatsinks", "xlengine", "endosteel"},
    },
}

local CDA3G = Cicada:New{
	description         = "Medium Skirmisher",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},

	customparams = {
		variant			= "CDA-3G",
		speed			= 120,
		price			= 12700,
		heatlimit 		= 10,--10 double
		armor			= 7.5,
		jumpjets		= 8,
		mods			= {"jumpjets", "beagle", "ferrofibrousarmour", "doubleheatsinks", "xlengine", "endosteel"},
		bap				= true,
    },
}

return lowerkeys({ 
	["CC_Cicada_CDA3C"] = CDA3C:New(),
	
	["FW_Cicada_CDA3M"] = CDA3M:New(),
	
	["DC_Cicada_CDA3F"] = CDA3F:New(),
	["FS_Cicada_CDA3F"] = CDA3F:New(),
	["LA_Cicada_CDA3F"] = CDA3F:New(),
	["FW_Cicada_CDA3F"] = CDA3F:New(),
	
	["FW_Cicada_CDA3G"] = CDA3G:New(),
})