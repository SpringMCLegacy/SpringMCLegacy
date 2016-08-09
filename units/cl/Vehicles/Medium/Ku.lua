local Ku = LightTank:New{
	name              	= "Ku",
	description			= "Medium Brawler",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "SSRM4",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "CERLBL",
		},
	},
	
	customparams = {
		tonnage			= 50,
		variant         = "",
		speed			= 60,
		price			= 10910,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 7},
		maxammo 		= {ac10 = 2, srm = 2},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["WF_Ku"] = Ku:New(),
})