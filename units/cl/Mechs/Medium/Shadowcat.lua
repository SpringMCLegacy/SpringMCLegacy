local Shadowcat = Medium:New{
	name				= "Shadow Cat",
	
	customparams = {
		tonnage			= 45,
    },
}
	
local Prime = Shadowcat:New{
	description         = "Medium Sniper",

	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
		},
	},

	customparams = {
		variant         = "Prime",
		speed			= 90,
		price			= 21560,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 7},
		maxammo 		= {gauss = 2},
		masc			= true,
		bap				= true,
		jumpjets		= 6,
    },
}

local A = Shadowcat:New{
	description         = "Medium Sniper",

	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "SSRM6",
		},
	},

	customparams = {
		variant         = "A",
		speed			= 90,
		price			= 22200,
		heatlimit 		= 26,
		armor			= {type = "ferro", tons = 7},
		maxammo 		= {srm = 2},
		masc			= true,
		bap				= true,
		jumpjets		= 6,
    },
}

local B = Shadowcat:New{
	description         = "Medium Sniper",

	weapons = {	
		[1] = {
			name	= "ALRM15",
		},
		[2] = {
			name	= "ALRM15",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
	},

	customparams = {
		variant         = "B",
		speed			= 90,
		price			= 24200,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 7},
		maxammo 		= {lrm = 4},
		masc			= true,
		bap				= true,
		jumpjets		= 6,
    },
}

return lowerkeys({
	["SJ_Shadowcat_Prime"] = Prime:New(),
	["SJ_Shadowcat_A"] = A:New(),
	["SJ_Shadowcat_B"] = B:New(),
	["WF_Shadowcat_Prime"] = Prime:New(),--for testing
	["WF_Shadowcat_A"] = A:New(),--for testing
	["WF_Shadowcat_B"] = B:New(),--for testing
})