local Chimera = Medium:New{
	name				= "Chimera",
	
	leaveTracks			= true,	
	trackType			= "Chimera",
	trackOffset			= 6,
	trackWidth			= 36,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 8.3,
		tonnage			= 40,
    },
}

local CMA1S = Chimera:New{
	description         = "Medium Skirmisher",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MRM20",
		},
	},

	customparams = {
		variant			= "CMA-1S",
		speed			= 90,
		price			= 11730,
		heatlimit 		= 13,--10 double
		armor			= 7,
		jumpjets		= 6,
		maxammo 		= {mrm = 2},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["FS_Chimera_CMA1S"] = CMA1S:New(),
	["DC_Chimera_CMA1S"] = CMA1S:New(),
	["LA_Chimera_CMA1S"] = CMA1S:New(),
})