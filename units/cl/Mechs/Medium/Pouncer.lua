local Pouncer = Medium:New{
	name				= "Pouncer",
	
	customparams = {
		tonnage		= 40,
    },
}

local Prime = Pouncer:New{
	description         = "Medium Ranged",
	
	weapons = {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
		},
		[3] = {
			name	= "CERSBL",
		},
	},

	customparams = {
		variant         = "Prime",
		speed			= 90,
		price			= 25570,
		heatlimit 		= 24,
		armor			= {type = "ferro", tons = 6},
		jumpjets		= 5,
    },
}

local B = Pouncer:New{
	description         = "Medium Multirole",
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "SSRM4",
		},
		[4] = {
			name	= "SSRM4",
		},
		[5] = {
			name	= "LRM10",
		},
	},

	customparams = {
		variant         = "B",
		speed			= 90,
		price			= 18360,
		heatlimit 		= 24,
		armor			= {type = "ferro", tons = 6},
		maxammo 		= {lrm = 1, srm = 2},
		jumpjets		= 5,
    },
}

local C = Pouncer:New{
	description         = "Medium Multirole",
	
	weapons = {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERSBL",
		},
		[5] = {
			name	= "CERSBL",
		},
		[6] = {
			name	= "CERSBL",
		},
	},

	customparams = {
		variant         = "C",
		speed			= 90,
		price			= 16530,
		heatlimit 		= 24,
		armor			= {type = "ferro", tons = 6},
		maxammo 		= {ac10 = 2},
		jumpjets		= 5,
    },
}

return lowerkeys({
	["WF_Pouncer_Prime"] = Prime:New(),
	["WF_Pouncer_B"] = B:New(),
	["WF_Pouncer_C"] = C:New(),
})