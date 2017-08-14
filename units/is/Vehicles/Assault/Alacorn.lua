local Alacorn = Tank:New{
	name              	= "Alacorn Mk VII",
	description         = "Superheavy Sniper Tank",
	trackWidth			= 34,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "Gauss",
			SlaveTo = 1,
		},
		[3] = {
			name	= "Gauss",
			SlaveTo = 1,
		},
	},

	customparams = {
		tonnage			= 95,
		variant         = "",
		speed			= 50,
		price			= 18500,
		heatlimit 		= 45,
		armor			= {type = "standard", tons = 13},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		maxammo 		= {gauss = 5},
		squadsize 		= 1,
		--replaces		= "fs_schrek",
	},
}

return lowerkeys({
	["FS_Alacorn"] = Alacorn:New(),
})