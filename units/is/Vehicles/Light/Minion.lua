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
		},
		[2] = {
			name	= "MPL",
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

local MinionTAG = Minion:New{
	description         = "Light Scout Hover",
	
	weapons 		= {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "TAG",
		},
	},
	
	customparams = {
		variant         = "TAG",
		speed			= 150,
		price			= 2850,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4},
		squadsize 		= 2,
    },
}

return lowerkeys({
	--["CC_MinionTAG"] = MinionTAG:New(),
	--["FS_Minion"] = MinionScout:New(),
})