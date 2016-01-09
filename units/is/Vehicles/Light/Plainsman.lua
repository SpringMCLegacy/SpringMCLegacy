local Plainsman = Hover:New{
	name              	= "Plainsman",
	description			= "Light Scout Hover",
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 140,
		price			= 4130,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
		maxammo 		= {srm = 1},
		squadsize 		= 2,
		bap				= true,
    },
}

return lowerkeys({
	--["LA_Plainsman"] = Plainsman:New(),
	--["CC_Plainsman"] = Plainsman:New(),
})