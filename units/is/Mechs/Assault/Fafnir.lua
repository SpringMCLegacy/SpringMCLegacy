local Fafnir = Assault:New{
	name				= "Fafnir",
	
	leaveTracks			= true,	
	trackType			= "Fafnir",
	trackOffset			= 6,
	trackWidth			= 46,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 7,
		tonnage			= 100,
    },
}

local FNR5 = Fafnir:New{
	description         = "Assault Brawler",
	weapons = {	
		[1] = {
			name	= "HeavyGauss",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "HeavyGauss",
			OnlyTargetCategory = "ground",
			SlaveTo = 1,
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
			SlaveTo = 1,
		},
	},
		
	customparams = {
		variant			= "FNR-5",
		speed			= 50,
		price			= 26360,
		heatlimit 		= 10,--10 double
		armor			= 19.5,
		maxammo 		= {hvgauss = 8},
		barrelrecoildist = {[1] = 5, [2] = 5},
		ecm 			= true,
		mods			= {"guardian", "doubleheatsinks", "endosteel"},
    },
}

return lowerkeys({
	["LA_Fafnir_FNR5"] = FNR5:New(),
})