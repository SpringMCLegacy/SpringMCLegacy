local Commando = Light:New{
	name              	= "Commando",
	
	customparams = {
		cockpitheight	= 8,
		tonnage 		= 25,
    },
}

local COM5S = Commando:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "ASRM6",
		},
		[2] = {
			name	= "SSRM2",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "COM-5S",
		speed			= 90,
		price			= 5570,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 3},
		maxammo 		= {srm = 2},
    },
}

local COM7S = Commando:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "ASRM4",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "COM-7S",
		speed			= 90,
		price			= 6580,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 3.5},
		maxammo 		= {srm = 2},
    },
}

return lowerkeys({
	--["LA_Commando_COM5S"] = COM5S:New(),
	["LA_Commando_COM7S"] = COM7S:New(),
})