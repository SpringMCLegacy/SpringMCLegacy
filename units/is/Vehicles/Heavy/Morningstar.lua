local Morningstar = Tank:New{
	name              	= "Morningstar",
	description         = "Heavy Strike Tank",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MG",
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 80,
		price			= 4120,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 9},
		maxammo 		= {ac10 = 2},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["FS_Morningstar"] = Morningstar,
})