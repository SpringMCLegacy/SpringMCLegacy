local Flea = Light:New{
	name				= "Flea",
	customparams = {
		cockpitheight	= 9,
		tonnage			= 20,
    },
}

local FLE17 = Flea:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "Flamer",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant         = "FLE-17",
		speed			= 90,
		price			= 5100,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3},
		masc 			= true,
    },
}

return lowerkeys({
	["CC_Flea_FLE17"] = FLE17:New(),
})