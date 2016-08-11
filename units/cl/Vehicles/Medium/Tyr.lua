local Tyr = Hover:New{
	name              	= "Tyr",
	description			= "Troop Transport",
	
	transportCapacity		= 5,
	transportSize = 1,	
	trackWidth			= 18,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "SSRM4",
		},
	},
	
	customparams = {
		tonnage			= 45,
		variant         = "",
		speed			= 150,
		price			= 12600,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 6.5},
		maxammo 		= {srm = 2},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["WF_Tyr"] = Tyr:New(),
})