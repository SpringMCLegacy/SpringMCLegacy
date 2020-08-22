local Epona = Hover:New{
	name              	= "Epona",
	description			= "Light Skirmisher",
	
	weapons 		= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[5] = {
			name	= "SSRM4",
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 55,
		variant         = "Prime",
		speed			= 150,
		price			= 14770,
		heatlimit 		= 20,
		armor			= 5,
		maxammo 		= {srm = 2},
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Epona"] = Epona:New(),
})