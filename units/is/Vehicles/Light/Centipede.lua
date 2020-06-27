local Centipede = Hover:New{
	name              	= "Centipede",

	description         = "Light Scout Hover",
	
	weapons 		= {	
		[1] = {
			name	= "MBL",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "Flamer",
			maxAngleDif = 60,
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
    },
}

return lowerkeys({
	--["LA_Centipede"] = Centipede:New(),
})