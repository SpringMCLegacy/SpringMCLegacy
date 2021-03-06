local Mistlynx = Light:New{
	name				= "Mist Lynx",
	
	customparams = {
		tonnage			= 25,
		cockpitheight	= 3,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}

local Prime = Mistlynx:New{
	description         = "Light Skirmisher",
	
	weapons = {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MG",
		},
	},

	customparams = {
		variant         = "Prime",
		speed			= 110,
		price			= 8710,
		heatlimit 		= 13,
		armor			= 3.5,
		maxammo 		= {lrm = 1, srm = 1},
		jumpjets		= 6,
		bap				= true,
    },
}

local B = Mistlynx:New{
	description         = "Light Striker",
	
	weapons = {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "CERSBL",
		},
	},

	customparams = {
		variant         = "B",
		speed			= 110,
		price			= 12090,
		heatlimit 		= 13,
		armor			= 3.5,
		maxammo 		= {srm = 2},
		jumpjets		= 6,
		bap				= true,
    },
}

local C = Mistlynx:New{
	description         = "Light Sniper",
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "AMS",
		},
	},

	customparams = {
		variant         = "C",
		speed			= 110,
		price			= 13200,
		heatlimit 		= 13,
		armor			= 3.5,
		maxammo 		= {srm = 2},
		jumpjets		= 6,
		bap				= true,
		ecm				= true,
    },
}

local E = Mistlynx:New{
	description         = "Light Skirmisher",
	
	weapons = {	
		[1] = {
			name	= "ATM6",
		},
		[2] = {
			name	= "CERSBL",
		},
		[3] = {
			name	= "CERSBL",
		},
		[4] = {
			name	= "CERSBL",
		},
		[5] = {
			name	= "CERSBL",
		},
	},

	customparams = {
		variant         = "E",
		speed			= 110,
		price			= 9970,
		heatlimit 		= 13,
		armor			= 3.5,
		maxammo 		= {atm = 2},
		jumpjets		= 6,
		bap				= true,
    },
}

return lowerkeys({
	--["SJ_Mistlynx_Prime"] = Prime:New(),
	--["SJ_Mistlynx_B"] = B:New(),
	--["SJ_Mistlynx_C"] = C:New(),
	--["SJ_Mistlynx_E"] = E:New(),
	["WF_Mistlynx_P"] = Prime:New(),
	["WF_Mistlynx_B"] = B:New(),
	["WF_Mistlynx_C"] = C:New(),
	["WF_Mistlynx_E"] = E:New(),
})