local Jagermech = Heavy:New{
	name				= "Jagermech",
		
	leaveTracks			= true,	
	trackType			= "Jagermech",
	trackOffset			= 6,
	trackWidth			= 46,
	trackStretch 		= 2,
	
    customparams = {
		cockpitheight	= 2,
		tonnage			= 65,
    },
}

local JM6DD = Jagermech:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "UAC5",
		},
		[3] = {
			name	= "AC2",
		},
		[4] = {
			name	= "AC2",
		},
		[5] = {
			name	= "MPL",
		},
		[6] = {
			name	= "MPL",
		},
	},
		
    customparams = {
		variant			= "JM6-DD",
		speed			= 60,
		price			= 9650,
		heatlimit 		= 10,
		armor			= 6.5,
		maxammo 		= {ac5 = 2, ac2 = 2},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 4, [4] = 4},
		mods			= {"ferrofibrousarmour", "xlengine", "case"},
    },
}

local JM6DG = Jagermech:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "Gauss",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
	},
		
    customparams = {
		variant			= "JM6-DG",
		speed			= 60,
		price			= 16610,
		heatlimit 		= 10,--10 single
		armor			= 6.5,
		maxammo 		= {gauss = 6},
		barrelrecoildist = {[1] = 5, [2] = 5},
		mods			= {"ferrofibrousarmour", "xlengine", "case"},
    },
}

local JM7D = Jagermech:New{
	description         = "Heavy Vanguard",
	weapons = {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "UAC5",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "ERLBL",
		},
		[5] = {
			name	= "MPL",
		},
		[6] = {
			name	= "MPL",
		},
	},
		
    customparams = {
		variant			= "JM7-D",
		tonnage			= 70,
		speed			= 60,
		price			= 19000, --15000
		heatlimit 		= 13,--13 double
		armor			= 11,
		maxammo 		= {ac5 = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
		mods			= {"ferrofibrousarmour", "doubleheatsinks", "xlengine", "case"},
    },
}

local JM7F = Jagermech:New{
	description         = "Heavy Vanguard",
	weapons = {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "RAC5",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "MPL",
		},
	},
		
    customparams = {
		variant			= "JM7-F",
		tonnage			= 70,
		speed			= 60,
		price			= 17740,
		heatlimit 		= 12,
		armor			= 11,
		maxammo 		= {ac5 = 4},
		ecm 			= true,
		mods			= {"guardian", "ferrofibrousarmour", "doubleheatsinks", "xlengine", "case", "targetingcomputer"},
    },
}

return lowerkeys({ 
	["DC_Jagermech_JM6DD"] = JM6DD:New(),
	["DC_Jagermech_JM7D"] = JM7D:New(),
	--["DC_Jagermech_JM7D"] = JM7D:New(),
	["FS_Jagermech_JM6DD"] = JM6DD:New(),
	["FS_Jagermech_JM7D"] = JM7D:New(),
	["FS_Jagermech_JM7F"] = JM7F:New(),
	--["FW_Jagermech_JM6DD"] = JM6DD:New(),
	["LA_Jagermech_JM6DG"] = JM6DG:New(),
	["LA_Jagermech_JM7D"] = JM7D:New(),
	--["CC_Jagermech_JM6DD"] = JM6DD:New(),
})