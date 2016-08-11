local Ares = LightTank:New{
	name              	= "Ares",
	trackWidth			= 16,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "LRM10",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 40,
		variant         = "",
		speed			= 60,
		price			= 11510,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4.5},
		maxammo 		= {lrm = 3},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["WF_Ares"] = Ares:New(),
})