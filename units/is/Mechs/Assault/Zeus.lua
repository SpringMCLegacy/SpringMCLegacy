local Zeus = Assault:New{
	name				= "Zeus",
    customparams = {
		cockpitheight	= 4.85,
		tonnage			= 80,
    },
}

local ZEU5S = Zeus:New{
	description         = "Assault Multirole",
	weapons 		= {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "ERLBL",
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
			name	= "ALRM15",
		},
	},
    customparams = {
		variant			= "ZEU-5S",
		speed			= 60,
		price			= 14990,
		heatlimit 		= 28,
		armor			= {type = "standard", tons = 11.5},
		maxammo 		= {ac5 = 2, lrm = 1},
		barrelrecoildist = {[1] = 5},
    },
}

local ZEU9S = Zeus:New{
	description         = "Assault Multirole",
	weapons 		= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "LRM15",
		},
	},
    customparams = {
		variant			= "ZEU-9S",
		speed			= 60,
		price			= 16390,
		heatlimit 		= 34,
		armor			= {type = "ferro", tons = 11},
		maxammo 		= {lrm = 1},
		barrelrecoildist = {[1] = 3},
    },
}

local ZEU9S2 = Zeus:New{
	description         = "Assault Ranged",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "ERLBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "LRM15",
		},
	},
    customparams = {
		variant			= "ZEU-9S2",
		speed			= 60,
		price			= 18580,
		heatlimit 		= 24,
		armor			= {type = "ferro", tons = 11},
		maxammo 		= {gauss = 3, lrm = 3},
		barrelrecoildist = {[1] = 5},
    },
}

return lowerkeys({
	LA_Zeus_ZEU5S = ZEU5S:New(),
	LA_Zeus_ZEU9S = ZEU9S:New(),
	LA_Zeus_ZEU9S2 = ZEU9S2:New(),
})