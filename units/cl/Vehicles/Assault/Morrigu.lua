local Morrigu = Tank:New{
	name              	= "Morrigu",
	description         = "Superheavy Sniper Tank",
	trackWidth			= 28,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "LRM15",
		},
		[5] = {
			name	= "SSRM2",
			mainDir = [[1 0 0]],
			maxAngleDif = 60,
		},
		[6] = {
			name	= "SSRM2",
			mainDir = [[-1 0 0]],
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 16850,
		heatlimit 		= 30,
		armor			= {type = "ferro", tons = 13},
		maxammo 		= {lrm = 3, srm = 2},
		hasecm			= true,
		squadsize 		= 1,
    },
}

return lowerkeys({
	["WF_Morrigu"] = Morrigu:New(),
})