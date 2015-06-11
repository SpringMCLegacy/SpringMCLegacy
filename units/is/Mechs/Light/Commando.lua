local Commando = Light:New{
	name              	= "Commando",
	customparams = {
		tonnage 		= 25,
    },
}

local COM5S = Commando:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "SRM6",
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
		artemis			= true,
    },
}

return lowerkeys({
	["LA_Commando_COM5S"] = COM5S:New(),
})