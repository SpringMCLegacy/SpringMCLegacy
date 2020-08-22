local Catapult = Heavy:New{
	name				= "Catapult",
	
	customparams = {
		cockpitheight	= 3.5,
		tonnage			= 65,
    },
}
	
local CPLTC1 = Catapult:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
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
		[6] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "CPLT-C1",
		speed			= 60,
		price			= 13990,
		heatlimit 		= 15,
		armor			= 10,
		maxammo 		= {lrm = 2},
		jumpjets		= 4,
    },
}

local CPLTC2 = Catapult:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
		[3] = {
			name	= "LBX2",
		},
		[4] = {
			name	= "LBX2",
		},
	},
		
	customparams = {
		variant			= "CPLT-C2",
		speed			= 60,
		price			= 13460,
		heatlimit 		= 15,
		armor			= 11.5,
		maxammo 		= {lrm = 4, ac2 = 1},
		jumpjets		= 4,
		mods			= {"artemislrm"},
    },
}

local CPLTC3 = Catapult:New{
	description         = "Heavy Missile Boat (Artillery)",
	weapons	= {	
		[1] = {
			name	= "ArrowIV",
		},
		[2] = {
			name	= "MBL",
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
		variant			= "CPLT-C3",
		speed			= 60,
		price			= 13680,
		heatlimit 		= 15,
		armor			= 10,
		maxammo 		= {arrow = 1},
		jumpjets		= 4,
    },
}

local CPLTC4 = Catapult:New{
	description         = "Heavy Missile Boat",
	weapons 		= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "ERSBL",
		},
		[4] = {
			name	= "ERSBL",
		},
	},

	customparams = {
		variant			= "CPLT-C4",
		speed			= 60,
		price			= 13580,
		heatlimit 		= 10,
		armor			= 10,
		maxammo 		= {lrm = 4},
		jumpjets		= 4,
    },
}
	
local CPLTK2 = Catapult:New{
	description         = "Heavy Brawler",
	weapons 		= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MG",
		},
		[6] = {
			name	= "MG",
		},
	},

	customparams = {
		variant			= "CPLT-K2",
		speed			= 60,
		price			= 13190,
		heatlimit 		= 20,
		armor			= 11,
    },
}

local CPLTK5 = Catapult:New{
	description         = "Heavy Skirmisher",
	weapons 		= {	
		[1] = {
			name	= "MRM30",
		},
		[2] = {
			name	= "MRM30",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "MPL",
		},
	},

	customparams = {
		variant			= "CPLT-K5",
		speed			= 60,
		price			= 14570,
		heatlimit 		= 16,--12 double
		armor			= 12.5,
		maxammo 		= {mrm = 4},
		jumpjets		= 4,
		mods			= {"doubleheatsinks"},
    },
}


return lowerkeys({
	["CC_Catapult_CPLTC1"] = CPLTC1:New(),
	["DC_Catapult_CPLTC1"] = CPLTC1:New(),
	--["LA_Catapult_CPLTC1"] = CPLTC1:New(),
	["FS_Catapult_CPLTC2"] = CPLTC2:New(),
	["CC_Catapult_CPLTC3"] = CPLTC3:New(),
	["CC_Catapult_CPLTC4"] = CPLTC4:New(),
	["DC_Catapult_CPLTK2"] = CPLTK2:New(),
	["DC_Catapult_CPLTK5"] = CPLTK5:New(),
})