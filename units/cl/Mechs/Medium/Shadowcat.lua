local Shadowcat = Medium:New{
	name				= "Shadow Cat",
	
	customparams = {
		tonnage			= 45,
		cockpitheight	= 1.4,
		bap				= true,
		mods			= {"jumpjets", "beagle", "ferrofibrousarmour", "doubleheatsinks", "masc"},
		omni			= true,
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
		heatlimit 		= 10,
		armor			= 7,
		maxammo 		= {gauss = 2},
		jumpjets		= 6,
    },
}

local A = Shadowcat:New{
	description         = "Medium Vanguard",

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
		heatlimit 		= 13,
		armor			= 7,
		maxammo 		= {srm = 2},
		jumpjets		= 6,
    },
}

local B = Shadowcat:New{
	description         = "Medium EWAR Missile Boat",

	weapons = {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
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
		heatlimit 		= 10,
		armor			= 7,
		maxammo 		= {lrm = 4},
		ecm				= true,
		mods			= {"guardian", "artemislrm"},
		jumpjets		= 6,
    },
}

return lowerkeys({
	["SJ_Shadowcat_P"] = Prime:New(),
	["SJ_Shadowcat_A"] = A:New(),
	["SJ_Shadowcat_B"] = B:New(),
})