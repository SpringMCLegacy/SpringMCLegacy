local Challenger = Tank:New{
	name              	= "Challenger",
	description         = "Heavy Strike Tank",
	trackWidth			= 32,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "Gauss",
		},
		[3] = {
			name	= "LRM10",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
		[6] = {
			name	= "SSRM2",
		},
		[7] = {
			name	= "SSRM2",
		},
		[8] = {
			name	= "AMS",
		},
	},

	customparams = {
		tonnage			= 90,
		variant         = "X",
		speed			= 50,
		price			= 10170,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 14},
		maxammo 		= {ac10 = 1, gauss = 2, lrm = 1, srm = 1},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
	},
}

return lowerkeys({
	--["FS_Challenger"] = Challenger:New(),
})