local Phantom = Medium:New{
	name				= "Phantom",
	
	leaveTracks			= true,	
	trackType			= "Phantom",
	trackOffset			= 6,
	trackWidth			= 26,
	trackStretch 		= 2,
	
	customparams = {
		tonnage			= 45,
		cockpitheight	= 10.7,
		mods			= {"ferrofibrousarmour", "doubleheatsinks", "endosteel", "xlengine"},
		omni			= true,
    },
}
	
local Prime = Phantom:New{
	description         = "Medium EWAR Scout",
	weapons	= {	
		[1] = {
			name	= "CERMBL",
		},
		[2] = {
			name	= "LRM5",
		},
		[3] = {
			name	= "CERSBL",
		},
		[4] = {
			name	= "TAG",
			SlaveTo = 3,
		},
	},
	customparams = {
		variant         = "Prime",
		speed			= 140,
		price			= 11590,
		heatlimit 		= 12,
		armor			= 6,
		maxammo 		= {lrm = 1},
		bap				= true,
		ecm				= true,
		mods			= {"beagle", "guardian"},
    },
}

local A = Phantom:New{
	description         = "Medium Vanguard",
	weapons	= {	
		[1] = {
			name	= "LRM5",
		},
		[2] = {
			name	= "LRM5",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERSBL",
			SlaveTo = 3,
		},
		[5] = {
			name	= "CERSBL",
		},
		[6] = {
			name	= "CERSBL",
			SlaveTo = 5,
		},
		[7] = {
			name	= "CERSBL",
		},
		[8] = {
			name	= "CERSBL",
			SlaveTo = 7,
		},
	},
	customparams = {
		variant         = "A",
		speed			= 140,
		price			= 14100,
		heatlimit 		= 12,
		armor			= 6,
		maxammo 		= {lrm = 1},
    },
}

local B = Phantom:New{
	description         = "Medium Skirmisher",
	weapons	= {	
		[1] = {
			name	= "SRM4",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERSBL",
			SlaveTo = 3,
		},
	},
	customparams = {
		variant         = "B",
		speed			= 140,
		price			= 10960,
		heatlimit 		= 12,
		armor			= 6,
		maxammo 		= {srm = 2},
		bap				= true,
		mods			= {"beagle"},
    },
}

local C = Phantom:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "CERSBL",
		},
		[2] = {
			name	= "CERSBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CERSBL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "CERSBL",
			SlaveTo = 1,
		},
		[5] = {
			name	= "CERSBL",
		},
		[6] = {
			name	= "CERSBL",
			SlaveTo = 5,
		},
		[7] = {
			name	= "CERSBL",
			SlaveTo = 5,
		},
		[8] = {
			name	= "CERSBL",
			SlaveTo = 5,
		},
		[9] = {
			name	= "CERMBL",
		},
		[10] = {
			name	= "Flamer",
		},
	},
	customparams = {
		variant         = "C",
		speed			= 140,
		price			= 15900,
		heatlimit 		= 12,
		armor			= 6,
		mods			= {"targetingcomputer"},
    },
}

return lowerkeys({
	["WF_Phantom_P"] = Prime:New(),
	["WF_Phantom_A"] = A:New(),
	["WF_Phantom_B"] = B:New(),
	["WF_Phantom_C"] = C:New(),
})