local Challenger = Tank:New{
	name              	= "Challenger",
	description         = "Heavy Strike Tank",
	trackWidth			= 34,--width to render the decal
	
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
			maxAngleDif = 60,
		},
		[5] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "SSRM2",
			mainDir = [[0.5 0 1]],
			maxAngleDif = 60,
		},
		[7] = {
			name	= "SSRM2",
			mainDir = [[-0.5 0 1]],
			maxAngleDif = 60,
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
		armor			= 14,
		maxammo 		= {ac10 = 1, gauss = 2, lrm = 1, srm = 1},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		--replaces		= "fs_behemoth",
		mods			= {"ferrofibrousarmour"},
	},
}

return lowerkeys({
	["FS_Challenger"] = Challenger:New(),
})