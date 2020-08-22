local Cossack = Light:New{
	name              	= "Cossack",
	
	customparams = {
		cockpitheight	= 7,
		tonnage 		= 20,
    },
}

local CSK1 = Cossack:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "C-SK1",
		speed			= 90,
		price			= 4650,
		heatlimit 		= 10,
		armor			= 3,
		maxammo 		= {srm = 1},
		jumpjets		= 6,
    },
}

return lowerkeys({
	["CC_Cossack_CSK1"] = CSK1:New(),
})