local Jenner = Light:New{
	name              	= "Jenner",
	customparams = {
		tonnage 		= 35,
    },
}

local JR7K = Jenner:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SRM4",
		},
	},
		
	customparams = {
		variant         = "JR7-K",
		speed			= 110,
		price			= 8890,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 3.5},
		maxammo 		= {srm = 1},
		jumpjets		= 5,
    },
}

return lowerkeys({
	["DC_Jenner_JR7K"] = JR7K:New(),
})