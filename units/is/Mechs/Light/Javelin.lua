local Javelin = Light:New{
	name              	= "Javelin",
	customparams = {
		tonnage 		= 30,
    },
}

local JVN11B = Javelin:New{
	description         = "Light Scout/EWAR Support",
	weapons	= {	
		[1] = {
			name	= "SRM4",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "TAG",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant         = "JVN11B",
		speed			= 90,
		price			= 15000,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 5},
		bap 			= true,
		ecm				= true,
		maxammo 		= {srm = 180},
    },
}

return lowerkeys({
	["FS_Javelin_JVN11B"] = JVN11B:New(),
})