local Goblin = LightTank:New{
	name              	= "Goblin",
	description			= "Medium Brawler",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "LPL",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		tonnage			= 45,
		variant         = "IFV",
		speed			= 60,
		price			= 4850,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 8},
		maxammo 		= {srm = 1},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["FS_Goblin"] = Goblin:New(),
	["FW_Goblin"] = Goblin:New(),
})