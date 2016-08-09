local Zorya = LightTank:New{
	name              	= "Zorya",
	trackWidth			= 16,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "LBX5",
		},
		[2] = {
			name	= "LRM10",
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 60,
		price			= 5620,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
		maxammo 		= {ac5 = 3, lrm = 2},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["WF_Zorya"] = Zorya:New(),
})