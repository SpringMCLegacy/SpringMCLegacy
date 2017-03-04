local Marauder = Heavy:New{
	name				= "Marauder",
	
	customparams = {
		cockpitheight	= 58,
		tonnage			= 75,
    },
}

local MAD5D = Marauder:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "LPL",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "ERPPC",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "SSRM2",
		},
	},
		
	customparams = {
		variant			= "MAD-5D",
		speed			= 60,
		price			= 17870,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 14},
		jumpjets		= 4,
		maxammo 		= {srm = 1},
    },
}

local MAD7D = Marauder:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
	},
		
	customparams = {
		variant			= "MAD-7D",
		speed			= 60,
		price			= 19860,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 14},
		maxammo 		= {ac5 = 2},
		ecm				= true,
    },
}

local MAD5S = Marauder:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "ERPPC",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant			= "MAD-5S",
		speed			= 60,
		price			= 17990,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 11.5},
		maxammo 		= {gauss = 1},
		barrelrecoildist = {[1] = 5},
    },
}

local MAD9S = Marauder:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "ERPPC",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
		[6] = {
			name	= "Flamer",
		},
	},
		
	customparams = {
		variant			= "MAD-9S",
		speed			= 60,
		price			= 17860,
		heatlimit 		= 28,
		armor			= {type = "standard", tons = 13},
		maxammo 		= {ac10 = 2},
		ecm				= true,
		bap				= true,
		barrelrecoildist = {[1] = 5},
    },
}

local MAD5L = Marauder:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
	},
		
	customparams = {
		variant			= "MAD-5L",
		speed			= 60,
		price			= 22860,
		heatlimit 		= 36,
		armor			= {type = "stealth", tons = 14},
		barrelrecoildist = {[1] = 5},
    },
}

local MAD5M = Marauder:New{
	description         = "Heavy Brawler",
	weapons = {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "LPL",
		},
		[3] = {
			name	= "LPL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant			= "MAD-5M",
		speed			= 60,
		price			= 14710,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 11.5},
		maxammo 		= {ac10 = 1},
		barrelrecoildist = {[1] = 5},
    },
}

local MAD9M = Marauder:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "ERLBL",
		},
		[5] = {
			name	= "SSRM6",
		},
		[6] = {
			name	= "SSRM6",
		},
		[7] = {
			name	= "TAG",
		},
	},
		
	customparams = {
		variant			= "MAD-9M",
		speed			= 60,
		price			= 17040,
		heatlimit 		= 32,
		armor			= {type = "ferro", tons = 12.5},
		maxammo 		= {srm = 2},
		barrelrecoildist = {[1] = 5},
		ecm				= true,
    },
}


return lowerkeys({
	["FS_Marauder_MAD5D"] = MAD5D:New(),
	["FS_Marauder_MAD7D"] = MAD7D:New(),
	["DC_Marauder_MAD5D"] = MAD5D:New(),
	["LA_Marauder_MAD5S"] = MAD5S:New(),
	["LA_Marauder_MAD9S"] = MAD9S:New(),
	["FW_Marauder_MAD5M"] = MAD5M:New(),
	["FW_Marauder_MAD9M"] = MAD9M:New(),
	["CC_Marauder_MAD5L"] = MAD5L:New(),
})