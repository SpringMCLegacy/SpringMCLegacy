local Uziel = Medium:New{
	name				= "Uziel",
	
	leaveTracks			= true,	
	trackType			= "Uziel",
	trackOffset			= 6,
	trackWidth			= 36,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 5.31,
		tonnage			= 50,
    },
}

local UZL2S = Uziel:New{
	description         = "Medium Sniper",
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "MG",
		},
	},

	customparams = {
		variant			= "UZL-2S",
		speed			= 90,
		price			= 13520,
		heatlimit 		= 10,--10 double
		armor			= 8,
		jumpjets		= 6,
		maxammo 		= {srm = 1},
		bap				= true,
		mods			= {"jumpjets", "beagle", "doubleheatsinks", "endosteel", "xlengine"},
    },
}

local UZL3S = Uziel:New{
	description         = "Medium Skirmisher",
	weapons	= {	
		[1] = {
			name	= "LBX2",
		},
		[2] = {
			name	= "LPL",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERSBL",
		},
		[6] = {
			name	= "ERSBL",
		},
	},

	customparams = {
		variant			= "UZL-3S",
		speed			= 90,
		price			= 11890,
		heatlimit 		= 11,--11 double
		armor			= 8,
		jumpjets		= 6,
		maxammo 		= {srm = 1, ac2 = 1},
		barrelrecoildist = {[1] = 4},
		mods			= {"jumpjets", "doubleheatsinks", "endosteel", "xlengine"},
    },
}

return lowerkeys({ 
	["LA_Uziel_UZL2S"] = UZL2S:New(),
	["LA_Uziel_UZL3S"] = UZL3S:New(),
})