local Cicada = Medium:New{
	name				= "Cicada",
	
	customparams = {
		cockpitheight	= 3,
		tonnage			= 40,
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
		variant			= "CMA-1S",
		speed			= 120,
		price			= 8120,
		heatlimit 		= 13,--10 double
		armor			= 4,
		maxammo 		= {ac5 = 1},
		barrelrecoildist = {[1] = 3},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["FW_Cicada_CDA3M"] = CDA3M:New(),
})