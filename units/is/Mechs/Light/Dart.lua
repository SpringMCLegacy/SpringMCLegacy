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
			name	= "SPL",
		},
		[2] = {
			name	= "SPL",
		},
		[3] = {
			name	= "SPL",
		},
	},
		
	customparams = {
		variant         = "DRT-3S",
		speed			= 140,
		price			= 4360,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
    },
}

return lowerkeys({
	["LA_Dart_DRT3S"] = DRT3S:New(),
})