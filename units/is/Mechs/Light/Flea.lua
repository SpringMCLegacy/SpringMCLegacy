local Flea = Light:New{
	customparams = {
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
		variant         = "FLE17",
		speed			= 90,
		price			= 9200,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3},
		masc 			= true,
    },
}

return lowerkeys({
	["CC_Flea_FLE17"] = FLE17:New(),
})