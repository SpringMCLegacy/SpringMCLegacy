local Rifleman = Heavy:New{
	name				= "Rifleman",
		
    customparams = {
		cockpitheight	= 4.8,
		tonnage			= 60,
    },
}

local RFL5D = Rifleman:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "LBL",
		},
		[4] = {
			name	= "LBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},
		
    customparams = {
		variant			= "RFL-5D",
		speed			= 60,
		price			= 13950,
		heatlimit 		= 23,--17 double
		armor			= 9,
		mods			= {"doubleheatsinks"},
    },
}

local RFL5M = Rifleman:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "UAC5",
		},
		[3] = {
			name	= "LBL",
		},
		[4] = {
			name	= "LBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},
		
    customparams = {
		variant			= "RFL-5M",
		speed			= 60,
		price			= 12270,
		heatlimit 		= 16,--12 double
		armor			= 8.5,
		maxammo 		= {ac5 = 1},
		barrelrecoildist = {[1] = 5, [2] = 5},
		mods			= {"doubleheatsinks"},
    },
}

local RFL6X = Rifleman:New{
	description         = "Heavy Brawler",
	weapons = {	
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
		[6] = {
			name	= "SBL",
		},
	},
		
    customparams = {
		variant			= "RFL-6X",
		speed			= 80,
		price			= 14640,
		heatlimit 		= 13,--10 double
		armor			= 11.5,
		maxammo 		= {ac10 = 4},
		barrelrecoildist = {[1] = 5, [2] = 5},
		mods			= {"doubleheatsinks"},
    },
}

local RFL7M = Rifleman:New{
	description         = "Heavy Sniper",
	weapons = {	
		[1] = {
			name	= "LightGauss",
		},
		[2] = {
			name	= "LightGauss",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
		[6] = {
			name	= "ERMBL",
		},
		[7] = {
			name	= "ERMBL",
		},
		[8] = {
			name	= "ERMBL",
		},
	},
		
    customparams = {
		variant			= "RFL-7M",
		speed			= 60,
		price			= 15210,
		heatlimit 		= 15,--11 double
		armor			= 11.5,
		maxammo 		= {ltgauss = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
		ecm				= true,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	--["FS_Rifleman_RFL5D"] = RFL5D:New(),
	--["FS_Rifleman_RFL6X"] = RFL6X:New(),
	--["LA_Rifleman_RFL5M"] = RFL5M:New(),
	--["FW_Rifleman_RFL5M"] = RFL5M:New(),
	["FW_Rifleman_RFL7M"] = RFL7M:New(),
})