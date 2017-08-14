local DemolisherII = Tank:New{
	name              	= "Demolisher II",
	description         = "Superheavy Assault Tank",
	trackWidth			= 34,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "LBX20",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MG",
			maxangleDif = 60,
		},
		[4] = {
			name	= "MG",
			maxangleDif = 60,
		},
	},

	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 50,
		price			= 16190,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 14.5},
		barrelrecoildist = {[1] = 4, [2] = 3},
		maxammo 		= {ac20 = 5},
		squadsize 		= 1,
		--replaces		= "la_demolisher",
	},
}

return lowerkeys({
	["LA_DemolisherII"] = DemolisherII:New(),
})