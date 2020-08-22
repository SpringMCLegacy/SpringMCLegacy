local Osiris = Light:New{
	name				= "Osiris",

	customparams = {
		cockpitheight	= 3.6,
		tonnage			= 30,
    },	
}

local OSR3D = Osiris:New{
	description         = "Light Striker",
	weapons = {	
		[1] = {
			name	= "ERMBL",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
		[6] = {
			name	= "MG",
		},
		[7] = {
			name	= "SRM6",
		},
	},
		
	customparams = {
		variant			= "OSR-3D",
		speed			= 120,
		price			= 11380,
		heatlimit 		= 13,--10 double
		armor			= 4.5,
		jumpjets		= 4,
		maxammo 		= {srm = 1},
		mods 			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

local OSR4D = Osiris:New{
	description         = "Light Striker",
	weapons = {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
		[6] = {
			name	= "ERMBL",
		},
	},
		
	customparams = {
		variant			= "OSR-4D",
		speed			= 120,
		price			= 12300,
		heatlimit 		= 13,--10 double
		armor			= 5.5,
		jumpjets		= 8,
		mods 			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

return lowerkeys({
	["FS_Osiris_OSR3D"] = OSR3D:New(),
	--["FS_Osiris_OSR4D"] = OSR4D:New(),
})