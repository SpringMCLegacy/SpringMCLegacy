local Direwolf = Assault:New{
	name				= "Dire Wolf",
	
	leaveTracks			= true,	
	trackType			= "Direwolf",
	trackOffset			= 6,
	trackWidth			= 46,
	trackStretch 		= 2,
	
	customparams = {
		tonnage			= 100,
		cockpitheight	= 16.26,
		mods			= {"doubleheatsinks", "xlengine"},
		omni			= true,
    },	
}

local Prime = Direwolf:New{
	description         = "Assault Vanguard",
	weapons	= {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "UAC5",
		},
		[3] = {
			name	= "CERLBL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "CERLBL",
			SlaveTo = 1,
		},
		[5] = {
			name	= "CERLBL",
			SlaveTo = 2,
		},
		[6] = {
			name	= "CERLBL",
			SlaveTo = 2,
		},
		[7] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[8] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[9] = {
			name	= "CMPL",
			SlaveTo = 2,
		},
		[10] = {
			name	= "CMPL",
			SlaveTo = 2,
		},
		[11] = {
			name	= "LRM10",
		},
	},
		
	customparams = {
		variant			= "Prime",
		speed			= 50,
		price			= 27120,
		heatlimit 		= 22,
		armor			= 19,
		maxammo 		= {ac5 = 2, lrm = 1},
		barrelrecoildist = {[1] = 1, [2] = 1},
    },
}

local A = Direwolf:New{
	description         = "Assault Brawler",
	weapons	= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "CLPL",
		},
		[3] = {
			name	= "CLPL",
			SlaveTo = 2,
		},
		[4] = {
			name	= "CLPL",
			SlaveTo = 2,
		},
		[5] = {
			name	= "SSRM6",
		},
		[6] = {
			name	= "SSRM6",
		},
		[7] = {
			name	= "AMS",
		},
	},
		
	customparams = {
		variant			= "A",
		speed			= 50,
		price			= 28960,
		heatlimit 		= 21,
		armor			= 19,
		maxammo 		= {gauss = 3, srm = 2},
		barrelrecoildist = {[1] = 5},
    },
}

local B = Direwolf:New{
	description         = "Assault Sniper",
	weapons	= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LBX10",
		},
		[4] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[5] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[6] = {
			name	= "UAC2",
		},
		[7] = {
			name	= "UAC2",
			SlaveTo = 6,
		},
		[8] = {
			name	= "UAC2",
			SlaveTo = 6,
		},
		[9] = {
			name	= "UAC2",
			SlaveTo = 6,
		},
	},
		
	customparams = {
		variant			= "B",
		speed			= 50,
		price			= 26090,
		heatlimit 		= 15,
		armor			= 19,
		maxammo 		= {ac2 = 2, ac10 = 2},
		barrelrecoildist = {[3] = 2},
    },
}

local C = Direwolf:New{
	description         = "Assault EWAR Vanguard",
	weapons	= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
			SlaveTo = 1,
		},
		[3] = {
			name	= "ATM6",
		},
		[4] = {
			name	= "ATM6",
			SlaveTo = 3,
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "CMPL",
			SlaveTo = 5,
		},
		[7] = {
			name	= "CMPL",
		},
		[8] = {
			name	= "CMPL",
			SlaveTo = 7,
		},
	},
		
	customparams = {
		variant			= "C",
		speed			= 50,
		price			= 36100,
		heatlimit 		= 23,
		armor			= 19,
		jumpjets		= 3,
		ecm				= true,
		maxammo 		= {atm = 2},
		mods			= {"jumpjets", "guardian", "targetingcomputer"},
    },
}

return lowerkeys({
	["WF_Direwolf_P"] = Prime:New(),
	["SJ_Direwolf_P"] = Prime:New(),
	["WF_Direwolf_A"] = A:New(),
	["SJ_Direwolf_A"] = A:New(),
	["WF_Direwolf_B"] = B:New(),
	["SJ_Direwolf_B"] = B:New(),
	["WF_Direwolf_C"] = C:New(),
	["SJ_Direwolf_C"] = C:New(),
})