local Firemoth = Light:New{
	name				= "Firemoth",
	
	customparams = {
		tonnage			= 20,
    },
}
	
local Prime = Firemoth:New{
	description         = "Light Skirmisher",

	weapons = {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "SRM4",
		},
	},

	customparams = {
		variant         = "Prime",
		speed			= 150,
		price			= 12510,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 2},
		maxammo 		= {srm = 2},
		masc 			= true,
    },
}

local A = Firemoth:New{
	description         = "Light Scout",

	weapons = {	
		[1] = {
			name	= "SSRM4",
		},
		[2] = {
			name	= "TAG",
		},
		[3] = {
			name	= "AMS",
		},
	},

	customparams = {
		variant         = "A",
		speed			= 150,
		price			= 6390,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 2},
		maxammo 		= {srm = 1},
		masc 			= true,
		bap				= true,
    },
}

local C = Firemoth:New{
	description         = "Light Missile Support",

	weapons = {	
		[1] = {
			name	= "LRM5",
		},
		[2] = {
			name	= "LRM5",
		},
		[3] = {
			name	= "AMS",
		},
	},

	customparams = {
		variant         = "C",
		speed			= 150,
		price			= 7590,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 2},
		maxammo 		= {lrm = 2},
		masc 			= true,
    },
}

return lowerkeys({
	["HH_Firemoth_Prime"] = Prime:New(),
	["HH_Firemoth_A"] = A:New(),
	["HH_Firemoth_C"] = C:New(),
	["GB_Firemoth_Prime"] = Prime:New(),
	["GB_Firemoth_A"] = A:New(),
	["GB_Firemoth_C"] = C:New(),
	["WF_Firemoth_Prime"] = Prime:New(),--for testing purposes
	["WF_Firemoth_A"] = A:New(),--for testing purposes
	["WF_Firemoth_C"] = C:New(),--for testing purposes
})