local Maxim = Hover:New{
	name              	= "Maxim",
	description			= "Battle Armor Transport",
	transportCapacity		= 5,
	transportSize = 1,	
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "LRM5",
			maxAngleDif = 60,
		},
		[5] = {
			name	= "LRM5",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "MG",
			SlaveTo = 1,
		},
		[7] = {
			name	= "MG",
			SlaveTo = 1,
		},
		[8] = {
			name	= "TAG",
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 50,
		variant         = "",
		speed			= 120,
		price			= 7960,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 9},
		maxammo 		= {srm = 2, lrm = 2},
		squadsize 		= 1,
		replaces		= "la_heavyapc",
    },
}

return lowerkeys({
	["CC_Maxim"] = Maxim:New(),
	["DC_Maxim"] = Maxim:New(),
	["FS_Maxim"] = Maxim:New(),
	["FW_Maxim"] = Maxim:New(),
	["LA_Maxim"] = Maxim:New(),
})