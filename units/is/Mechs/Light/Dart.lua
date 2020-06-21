local Dart = Light:New{
	name              	= "Dart",
	
	customparams = {
		cockpitheight	= 43,
		tonnage			= 25,
    },
	
	sounds = {
		select = {
			'Voice_SelectA_1',
			'Voice_SelectA_2',
			'Voice_SelectA_3',
		},
		ok = {
			'Voice_OKA_1',
			'Voice_OKA_2',
			'Voice_OKA_3',
		},
		arrived = {
			'Voice_ArrivedA_1',
			'Voice_ArrivedA_2',
		},
	},
}

local DRT3S = Dart:New{
	description         = "Light Scout",
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