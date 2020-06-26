local PoIIBase = Tank:New{
	name              	= "Po II",
	description         = "Heavy Striker Tank",
	
	trackWidth			= 30,--width to render the decal
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 60,
		price			= 11810,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 11},
		maxammo 		= {ac20 = 3, lrm = 1, srm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
    },
}

local PoII = PoIIBase:New{
	weapons	= {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "LRM5",
		},
		[3] = {
			name	= "LRM5",
		},
		[4] = {
			name	= "SSRM2",
		},
		[5] = {
			name	= "SSRM2",
		},
		[6] = {
			name	= "MG",
		},
		[7] = {
			name	= "MG",
		},
	},
}

	
return lowerkeys({
	["CC_PoII"] = PoII:New(),
})