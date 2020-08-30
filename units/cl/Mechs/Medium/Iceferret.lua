local Iceferret = Medium:New{
	name				= "Ice Ferret",
	
	customparams = {
		tonnage			= 45,
		cockpitheight	= 6,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}
	
local Prime = Iceferret:New{
	description         = "Medium Sniper",
	weapons	= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERSBL",
		},
		[3] = {
			name	= "SSRM2",
		},
	},
	customparams = {
		variant         = "Prime",
		speed			= 120,
		price			= 16780,
		heatlimit 		= 16,
		armor			= 7.5,
		maxammo 		= {srm = 1},
		bap				= true,
    },
}

local B = Iceferret:New{
	description         = "Medium Multirole",
	weapons	= {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "SRM6",
		},
	},
	customparams = {
		variant         = "B",
		speed			= 120,
		price			= 14610,
		heatlimit 		= 16,
		armor			= 7.5,
		maxammo 		= {srm = 2},
    },
}

local D = Iceferret:New{
	description         = "Medium Striker",
	weapons	= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
		},
		[3] = {
			name	= "CMPL",
		},
		[4] = {
			name	= "CMPL",
		},
		[5] = {
			name	= "AMS",
		},
	},
	customparams = {
		variant         = "D",
		speed			= 120,
		price			= 16530,
		heatlimit 		= 16,
		armor			= 7.5,
    },
}

return lowerkeys({
	["WF_Iceferret_P"] = Prime:New(),
	["WF_Iceferret_B"] = B:New(),
	["WF_Iceferret_D"] = D:New(),
})