local Goblin = LightTank:New{
	name              	= "Goblin",
	description			= "Troop Transport",
	trackWidth			= 23,--width to render the decal
	
	transportCapacity		= 5,
	transportSize = 1,	
	
	weapons	= {	
		[1] = {
			name	= "LPL",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MG",
			mainDir = [[-1 0 1]],
			maxAngleDif = 90,
		},
		[4] = {
			name	= "MG",
			mainDir = [[1 0 1]],
			maxAngleDif = 90,
		},
		[5] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		tonnage			= 45,
		variant         = "IFV",
		speed			= 60,
		price			= 7900,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 8},
		maxammo 		= {srm = 2},
		squadsize 		= 1,
		replaces		= "fs_heavyapc",
    },
}

return lowerkeys({
	["FS_Goblin"] = Goblin:New(),
})