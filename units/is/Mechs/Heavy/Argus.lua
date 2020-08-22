local Argus = Heavy:New{
	name				= "Argus",
		
    customparams = {
		cockpitheight	= 9.7,
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
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "LRM10",
		},
	},
		
    customparams = {
		variant			= "AGS-4D",
		speed			= 80,
		price			= 18380, --16380
		heatlimit 		= 16,--12 double
		armor			= 12,
		bap				= true,
		maxammo 		= {ac5 = 2, lrm = 2},
		barrelrecoildist = {[1] = 4},
		mods			= {"targetingcomputer", "doubleheatsinks"},
    },
}

return lowerkeys({ 
	["FS_Argus_AGS4D"] = AGS4D:New(),
})