local DIMorgan = Tank:New{
	name              	= "DI Morgan",
	description         = "Superheavy Sniper Tank",
	trackWidth			= 34,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
			SlaveTo = 1,
		},
		[3] = {
			name	= "ERPPC",
			SlaveTo = 1,
		},
		[4] = {
			name	= "MG",
			maxAngleDif = 180,
		},
		[5] = {
			name	= "MG",
			maxAngleDif = 180,
			SlaveTo = 4,
		},
	},

	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 50,
		price			= 13900,
		heatlimit 		= 45,
		armor			= {type = "ferro", tons = 10.5},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		squadsize 		= 1,
		--replaces		= "la_schrek",
	},
}

return lowerkeys({
	["LA_DIMorgan"] = DIMorgan:New(),
})