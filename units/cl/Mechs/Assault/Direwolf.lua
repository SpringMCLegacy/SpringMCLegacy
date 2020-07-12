local Direwolf = Medium:New{
	name				= "Dire Wolf",

	customparams = {
		tonnage			= 100,
    },	
}

local Prime = Direwolf:New{
	description         = "Assault Multirole",
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
		heatlimit 		= 44,
		armor			= {type = "standard", tons = 19},
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
		heatlimit 		= 42,
		armor			= {type = "standard", tons = 19},
		maxammo 		= {gauss = 3, srm = 2},
		barrelrecoildist = {[1] = 5},
    },
}

return lowerkeys({
	["WF_Direwolf_Prime"] = Prime:New(),
	["WF_Direwolf_A"] = A:New(),
})