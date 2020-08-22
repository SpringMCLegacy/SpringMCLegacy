local Gurteltier = Tank:New{
	name              	= "Gurteltier",
	description         = "Superheavy Strike Tank",
	trackWidth			= 34,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "MML7",
		},
		[4] = {
			name	= "MG",
			mainDir = [[-1 0 0]],
			maxAngleDif = 120,
		},
		[5] = {
			name	= "MG",
			mainDir = [[1 0 0]],
			maxAngleDif = 120,
		},
	},

	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 50,
		price			= 21250,
		heatlimit 		= 20,
		armor			= 19,
		maxammo 		= {gauss = 2, mml = 2},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		--replaces		= "la_behemoth",
	},
}

return lowerkeys({
	["LA_Gurteltier"] = Gurteltier:New(),
})