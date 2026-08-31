local Blackjack = Medium:New{
	name				= "Blackjack",

	leaveTracks			= true,	
	trackType			= "Blackjack",
	trackOffset			= 6,
	trackWidth			= 32,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 12.71,
		tonnage			= 50,
		speed			= 60,
		heatlimit 		= 10,--10 double
		omni			= true,
		jumpjets		= 4,
		armor			= 9.5,
		mods			= {"endosteel", "jumpjets", "xlengine", "doubleheatsinks"},
    },	
}

local BJ2OP = Blackjack:New{
	description         = "Medium Vanguard",
	weapons	= {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "UAC5",
		},
		[3] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[5] = {
			name	= "MBL",
			SlaveTo = 2,
		},
		[6] = {
			name	= "MBL",
			SlaveTo = 2,
		},
		[7] = {
			name	= "MG",
		},
		[8] = {
			name	= "MG",
			SlaveTo = 7,
		},
		[9] = {
			name	= "MG",
		},
		[10] = {
			name	= "MG",
			SlaveTo = 9,
		},
	},
		
	customparams = {
		variant			= "BJ2-O Prime",
		price			= 12010,
		maxammo 		= {ac5 = 2},
		barrelrecoildist = {[1] = 3, [2] = 3},
    },
}

local BJ2OA = Blackjack:New{
	description         = "Medium Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant			= "BJ2-O A",
		price			= 13180,
		maxammo 		= {lrm = 4},
    },
}

local BJ2OB = Blackjack:New{
	description         = "Medium Sniper",
	weapons	= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "LRM10",
		},
		[3] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant			= "BJ2-O B",
		price			= 13230,
		maxammo 		= {gauss = 2, lrm = 2},
		mods			= {"c3slave", "artemislrm"},
		barrelrecoildist = {[1] = 3},
    },
}

local BJ2OC = Blackjack:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "LBX10",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant			= "BJ2-O C",
		price			= 11890,
		maxammo 		= {ac10 = 2},
		barrelrecoildist = {[1] = 3, [2] = 3},
    },
}

return lowerkeys({
	["CC_Blackjack_BJ2OP"] = BJ2OP:New(),
	["CC_Blackjack_BJ2OA"] = BJ2OA:New(),
	["CC_Blackjack_BJ2OB"] = BJ2OB:New(),
	["CC_Blackjack_BJ2OC"] = BJ2OC:New(),
	
	["DC_Blackjack_BJ2OP"] = BJ2OP:New(),
	["DC_Blackjack_BJ2OA"] = BJ2OA:New(),
	["DC_Blackjack_BJ2OB"] = BJ2OB:New(),
	["DC_Blackjack_BJ2OC"] = BJ2OC:New(),
	
	["FS_Blackjack_BJ2OP"] = BJ2OP:New(),
	["FS_Blackjack_BJ2OA"] = BJ2OA:New(),
	["FS_Blackjack_BJ2OB"] = BJ2OB:New(),
	["FS_Blackjack_BJ2OC"] = BJ2OC:New(),
	
	["FW_Blackjack_BJ2OP"] = BJ2OP:New(),
	["FW_Blackjack_BJ2OA"] = BJ2OA:New(),
	["FW_Blackjack_BJ2OB"] = BJ2OB:New(),
	["FW_Blackjack_BJ2OC"] = BJ2OC:New(),
	
	["LA_Blackjack_BJ2OP"] = BJ2OP:New(),
	["LA_Blackjack_BJ2OA"] = BJ2OA:New(),
	["LA_Blackjack_BJ2OB"] = BJ2OB:New(),
	["LA_Blackjack_BJ2OC"] = BJ2OC:New(),
})