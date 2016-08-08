local Odin = LightTank:New{
	name              	= "Odin",
	trackWidth			= 18,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CERSBL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "SSRM2",
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 20,
		variant         = "",
		speed			= 130,
		price			= 6910,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 1.5},
		maxammo 		= {srm = 2},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["WF_Odin"] = Odin:New(),
})