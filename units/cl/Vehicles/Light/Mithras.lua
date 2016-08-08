local Mithras = LightTank:New{
	name              	= "Mithras",
	trackWidth			= 16,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "CERMBL",
		},
		[2] = {
			name	= "CERMBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "UAC2",
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 25,
		variant         = "",
		speed			= 90,
		price			= 6700,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 3},
		maxammo 		= {ac2 = 3},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["WF_Mithras"] = Mithras:New(),
})