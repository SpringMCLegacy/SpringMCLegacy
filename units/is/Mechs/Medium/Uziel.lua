local Uziel = Medium:New{
	name				= "Uziel",
	
	customparams = {
		cockpitheight	= 1,
		tonnage			= 50,
    },
}

local UZL2S = Uziel:New{
	description         = "Medium Skirmisher",
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
		heatlimit 		= 13,--10 double
		armor			= 8,
		jumpjets		= 6,
		maxammo 		= {srm = 1},
		bap				= true,
		mods			= {"doubleheatsinks"},
    },
}

local UZL3S = Uziel:New{
	description         = "Medium Skirmisher",
	weapons	= {	
		[1] = {
			name	= "AC2",
		},
		[2] = {
			name	= "LPL",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "ERSBL",
		},
		[5] = {
			name	= "ERSBL",
		},
		[6] = {
			name	= "ERMBL",
		},
	},

	customparams = {
		variant			= "UZL-2S",
		speed			= 90,
		price			= 11890,
		heatlimit 		= 13,--10 double
		armor			= 8,
		jumpjets		= 6,
		maxammo 		= {srm = 1, ac2 = 1},
		barrelrecoildist = {[1] = 4},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["LA_Uziel_UZL2S"] = UZL2S:New(),
	--["LA_Uziel_UZL3S"] = UZL3S:New(),
})