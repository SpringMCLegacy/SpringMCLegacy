local Mauler = Assault:New{
	name				= "Mauler",

	customparams = {
		cockpitheight	= 8.9,
		tonnage			= "90",
    },
}
	
local MAL1R = Mauler:New{
	description         = "Assault Sniper",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "AC2",
		},
		[4] = {
			name	= "AC2",
		},
		[5] = {
			name	= "AC2",
		},
		[6] = {
			name	= "AC2",
		},
		[7] = {
			name	= "LRM15",
		},
		[8] = {
			name	= "LRM15",
		},
	},
		
    customparams = {
		variant			= "MAL-1R",
		speed			= 50,
		price			= 14600,
		heatlimit 		= 22,
		armor			= {type = "ferro", tons = 11.5},
		maxammo 		= {lrm = 4, ac2 = 2},
    },
}

local MAL3R = Mauler:New{
	description         = "Assault Striker",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "LBX10",
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "LRM15",
		},
		[5] = {
			name	= "SBL",
		},
	},
		
    customparams = {
		variant			= "MAL-3R",
		speed			= 50,
		price			= 18770,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 16},
		maxammo 		= {lrm = 4, ac10 = 4},
		jumpjets		= 3,
		barrelrecoildist = {[1] = 5, [2] = 5},
    },
}
	
return lowerkeys({ 
	["DC_Mauler_MAL1R"] = MAL1R:New(),
	["DC_Mauler_MAL3R"] = MAL3R:New(),
})