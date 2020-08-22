local Timberwolf = Heavy:New{
	name				= "Timber Wolf",
		
    customparams = {
		cockpitheight	= 9.6,
		tonnage			= 75,
    },
}

local Prime = Timberwolf:New{
	description         = "Heavy Multirole",
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "MG",
		},
		[7] = {
			name	= "MG",
		},
		[8] = {
			name	= "LRM20",
		},
		[9] = {
			name	= "LRM20",
		},
	},
		
    customparams = {
		variant			= "Prime",
		speed			= 80,
		price			= 27370,
		heatlimit 		= 34,
		armor			= 12,
		maxammo 		= {lrm = 2},
		mods			= {"ferrofibrousarmour"},
    },
}

local A = Timberwolf:New{
	description         = "Heavy Multirole",
	weapons = {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
		},
		[3] = {
			name	= "CMPL",
		},
		[4] = {
			name	= "CMPL",
		},
		[5] = {
			name	= "CMPL",
			SlaveTo = 4,
		},
		[6] = {
			name	= "SSRM6",
		},
	},
		
    customparams = {
		variant			= "A",
		speed			= 80,
		price			= 28540,
		heatlimit 		= 40,
		armor			= 12,
		maxammo 		= {srm = 1},
		mods			= {"ferrofibrousarmour"},
    },
}

local E = Timberwolf:New{
	description         = "Heavy Ranged",
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "TAG",
		},
		[4] = {
			name	= "ATM9",
		},
		[5] = {
			name	= "ATM9",
		},
	},
		
    customparams = {
		variant			= "E",
		speed			= 80,
		price			= 24440,
		heatlimit 		= 36,
		armor			= 12,
		maxammo 		= {atm = 6},
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({ 
	["WF_Timberwolf_Prime"] = Prime:New(),
	["WF_Timberwolf_A"] = A:New(),
	["WF_Timberwolf_E"] = E:New(),
})