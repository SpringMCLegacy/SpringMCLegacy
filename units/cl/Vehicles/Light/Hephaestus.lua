local Hephaestus = Hover:New{
	name              	= "Hephaestus",
	description			= "Light Harasser",
	
	weapons 		= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "TAG",
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "Prime",
		speed			= 130,
		price			= 7770,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 5},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["WF_Hephaestus"] = Hephaestus:New(),
})