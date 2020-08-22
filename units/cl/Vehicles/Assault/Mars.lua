local Mars = Tank:New{
	name              	= "Mars",
	description         = "Superheavy Striker Tank",
	trackType			= "Mars",--hueg like xbox
	trackWidth			= 33,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "CERLBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LBX10",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
		[5] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
		[7] = {
			name	= "MG",
			SlaveTo = 1,
		},
		[8] = {
			name	= "MG",
			SlaveTo = 1,
		},
		[9] = {
			name	= "SSRM6",
			mainDir = [[-1 0 1]],
			maxAngleDif = 90,
		},
		[10] = {
			name	= "SSRM6",
			mainDir = [[1 0 1]],
			maxAngleDif = 90,
		},
	},
	
	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 30,
		price			= 20760,
		heatlimit 		= 20,
		armor			= 11.5,
		maxammo 		= {gauss = 2, ac10 = 2, lrm = 3, srm = 2},
		barrelrecoildist = {[1] = 4, [3] = 2},
		hasecm			= true,
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Mars"] = Mars:New(),
})