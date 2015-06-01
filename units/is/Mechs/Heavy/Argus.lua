local Argus = Heavy:New{
	name				= "Argus",
		
    customparams = {
		tonnage			= 60,
    },
}

local AGS4D = Argus:New{
	description         = "Heavy Skirmisher",
	weapons = {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "LRM10",
		},
	},
		
    customparams = {
		variant			= "AGS-4D",
		speed			= 80,
		price			= 29000,
		heatlimit 		= 24,
		armor			= {type = "standard", tons = 12},
		maxammo 		= {ac5 = 2, lrm = 2},
		barrelrecoildist = {[1] = 4},
    },
}

return lowerkeys({ 
	["FS_Argus_AGS4D"] = AGS4D,
})