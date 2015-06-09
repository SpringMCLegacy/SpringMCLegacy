local Dart = Light:New{
	name              	= "Dart",
	customparams = {
		tonnage			= 25,
    },
}

local DRT3S = Dart:New{
	description         = "Light Skirmisher",
	weapons = {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "DRT-4S",
		speed			= 140,
		price			= 6560,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
    },
}

return lowerkeys({
	["LA_Dart_DRT3S"] = DRT3S:New(),
})