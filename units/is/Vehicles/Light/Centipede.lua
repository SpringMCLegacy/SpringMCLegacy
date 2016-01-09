local Centipede = Hover:New{
	name              	= "Centipede",

	description         = "Light Scout Hover",
	
	weapons 		= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "Flamer",
		},
		[3] = {
			name	= "TAG",
		},
	},
	
	customparams = {
		tonnage			= 20,
		variant         = "Scout",
		speed			= 120,
		price			= 1650,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3},
		squadsize 		= 2,
		bap				= true,
		ecm				= true,
    },
}

return lowerkeys({
	--["LA_Centipede"] = Centipede:New(),
})