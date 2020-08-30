local Gargoyle = Heavy:New{
	name				= "Gargoyle",
		
    customparams = {
		cockpitheight	= 10.5,
		tonnage			= 80,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}

local Prime = Gargoyle:New{
	description         = "Assault Skirmisher",
	weapons = {	
		[1] = {
			name	= "LBX5",
		},
		[2] = {
			name	= "LBX5",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "SRM6",
		},
	},
		
    customparams = {
		variant			= "Prime",
		speed			= 80,
		price			= 15370,
		heatlimit 		= 21,
		armor			= 11,
		maxammo 		= {ac5 = 3, srm = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
    },
}

local A = Gargoyle:New{
	description         = "Assault Sniper",
	weapons = {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CLPL",
		},
		[4] = {
			name	= "CERMBL",
			SlaveTo = 3,
		},
		[5] = {
			name	= "CMPL",
			SlaveTo = 3,
		},
		[6] = {
			name	= "CERSBL",
			SlaveTo = 3,
		},
	},
		
    customparams = {
		variant			= "A",
		speed			= 80,
		price			= 26890,
		heatlimit 		= 21,
		armor			= 11,
		maxammo 		= {srm = 1},
		barrelrecoildist = {[1] = 5, [2] = 5},
    },
}

local C = Gargoyle:New{
	description         = "Assault Striker",
	weapons = {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
			SlaveTo = 2,
		},
		[4] = {
			name	= "CERMBL",
			SlaveTo = 2,
		},
		[5] = {
			name	= "CERMBL",
			SlaveTo = 2,
		},
		[6] = {
			name	= "CERMBL",
			SlaveTo = 2,
		},
		[7] = {
			name	= "CERMBL",
			SlaveTo = 2,
		},
	},
		
    customparams = {
		variant			= "C",
		speed			= 80,
		price			= 24170,
		heatlimit 		= 21,
		armor			= 11,
		maxammo 		= {ac20 = 3},
		barrelrecoildist = {[1] = 2},
    },
}

return lowerkeys({ 
	["WF_Gargoyle_P"] = Prime:New(),
	["WF_Gargoyle_A"] = A:New(),
	["WF_Gargoyle_C"] = C:New(),
})