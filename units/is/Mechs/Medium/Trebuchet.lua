local Trebuchet = Medium:New{
	name				= "Trebuchet",

	customparams = {
		cockpitheight	= 7,
		tonnage			= 50,
    },
}
	
local TBT5N = Trebuchet:New{
	description         = "Medium Missile Boat",
	weapons = {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "TBT-5N",
		speed			= 80,
		price			= 11910,
		heatlimit 		= 10,
		armor			= 7.5,
		maxammo 		= {lrm = 2},
    },
}

local TBT5S = Trebuchet:New{
	description         = "Medium Striker",
	weapons = {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
	},
		
    customparams = {
		variant			= "TBT-5S",
		speed			= 80,
		price			= 9840,
		heatlimit 		= 18,
		armor			= 7.5,
		maxammo 		= {srm = 2},
    },
}

local TBT9K = Trebuchet:New{
	description         = "Medium Skirmisher",
	weapons = {	
		[1] = {
			name	= "MRM20",
		},
		[2] = {
			name	= "MRM20",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
	},
		
    customparams = {
		variant			= "TBT-9K",
		speed			= 80,
		price			= 13290,
		heatlimit 		= 13,--10 double
		armor			= 9,
		jumpjets		= 5,
		maxammo 		= {mrm = 3},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["FW_Trebuchet_TBT5N"] = TBT5N:New(),
	["FW_Trebuchet_TBT5S"] = TBT5S:New(),
	["DC_Trebuchet_TBT9K"] = TBT9K:New(),
})