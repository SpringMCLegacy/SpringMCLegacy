local Shadowcat = Medium:New{
	name				= "Shadow Cat",
	
	customparams = {
		tonnage			= 45,
		cockpitheight	= 1.4,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}
	
local Prime = Shadowcat:New{
	description         = "Medium Ranged",

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
		heatlimit 		= 13,
		armor			= 7,
		maxammo 		= {gauss = 2},
		masc			= true,
		bap				= true,
		jumpjets		= 6,
    },
}

local A = Shadowcat:New{
	description         = "Medium Multirole",

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
		heatlimit 		= 17,
		armor			= 7,
		maxammo 		= {srm = 2},
		masc			= true,
		bap				= true,
		jumpjets		= 6,
    },
}

local B = Shadowcat:New{
	description         = "Medium Ranged",

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
		heatlimit 		= 13,
		armor			= 7,
		maxammo 		= {lrm = 4},
		masc			= true,
		bap				= true,
		jumpjets		= 6,
    },
}

return lowerkeys({
	--["WF_Shadowcat_Prime"] = Prime:New(),
	--["WF_Shadowcat_A"] = A:New(),
	--["WF_Shadowcat_B"] = B:New(),
})