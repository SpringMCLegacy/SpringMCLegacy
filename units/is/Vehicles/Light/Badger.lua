local Badger = LightTank:New{
	name              	= "Badger",
	trackWidth			= 20,
	
	customparams = {
		tonnage			= 30,
    },
}

local Prime = Badger:New{
	description         = "Troop Transport",
	
	transportCapacity		= 5,
	transportSize = 1,	
	
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "SRM2",
		},
	},
	
customparams = {
		variant         = "Prime",
		speed			= 80,
		price			= 3340,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5},
		maxammo 		= {srm = 1},
		unittype 		= "apc",
		squadsize 		= 1,
    },
}

return lowerkeys({
	["FS_Badger_Prime"] = Prime:New(),
})