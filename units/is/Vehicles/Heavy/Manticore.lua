local ManticoreBase = Tank:New{
	name              	= "Manticore",
	description         = "Heavy Striker Tank",
	
	trackWidth			= 27,--width to render the decal
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 60,
		price			= 7050,
		heatlimit 		= 10,
		armor			= 10,
		maxammo 		= {lrm = 1, srm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
    },
}

local Manticore = ManticoreBase:New{
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "MBL",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "LRM10",
		},
	},
}

local ManticoreD = ManticoreBase:New{
	description         = "Heavy Brawler Tank",
	
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "SSRM6",
		},
	},
	
	customparams = {
		variant         = "(Davion)",
		speed			= 60,
		price			= 8000,
		heatlimit 		= 10,
		armor			= 10,
		maxammo 		= {ac10 = 2, srm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		replaces		= "fs_manticore",
    },
}

local ManticoreS = ManticoreBase:New{
	description         = "Heavy Brawler Tank",
	
	weapons	= {	
		[1] = {
			name	= "LPL",
		},
		[2] = {
			name	= "SSRM2",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "LRM10",
		},
	},
	
	customparams = {
		variant         = "(Steiner)",
		speed			= 80,
		price			= 8000,
		heatlimit 		= 10,
		armor			= 10,
		maxammo 		= {lrm = 1, srm = 1},
		squadsize 		= 1,
		replaces		= "la_manticore",
    },
}
	
return lowerkeys({
	["CC_Manticore"] = Manticore:New(),
	["DC_Manticore"] = Manticore:New(),
	["FS_Manticore"] = Manticore:New(),
	--["FS_ManticoreD"] = ManticoreD:New(),
	["FW_Manticore"] = Manticore:New(),
	["LA_Manticore"] = Manticore:New(),
	--["LA_ManticoreS"] = ManticoreS:New(),
})