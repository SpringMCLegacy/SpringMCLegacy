local Pegasus = Hover:New{
	name              	= "Pegasus",
	description			= "Light EWAR Hover",
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "TAG",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "EWAR",
		speed			= 140,
		price			= 7060,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4},
		maxammo 		= {srm = 1},
		squadsize 		= 1,
		bap				= true,
		ecm				= true,
    },
}

return lowerkeys({
	["DC_Pegasus"] = Pegasus:New(),
})