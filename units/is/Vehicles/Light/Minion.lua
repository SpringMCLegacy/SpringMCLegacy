local Minion = Hover:New{
	name              	= "Minion",
	
	customparams = {
		tonnage			= 20,
    },
}

local MinionScout = Minion:New{
	description         = "Light Scout Hover",
	
	weapons 		= {	
		[1] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		variant         = "Scout",
		speed			= 140,
		price			= 2850,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["FS_Minion"] = MinionScout:New(),
})