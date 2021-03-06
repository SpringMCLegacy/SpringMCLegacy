local Fafnir = Assault:New{
	name				= "Fafnir",
	
	customparams = {
		cockpitheight	= 7,
		tonnage			= 100,
    },
}

local FNR5 = Fafnir:New{
	description         = "Assault Juggernaut",
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
		heatlimit 		= 13,--10 double
		armor			= 19.5,
		maxammo 		= {hvgauss = 8},
		barrelrecoildist = {[1] = 5, [2] = 5},
		ecm 			= true,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({
	["LA_Fafnir_FNR5"] = FNR5:New(),
})