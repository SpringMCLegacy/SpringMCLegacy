local Adder = Light:New{
	name				= "Adder",

    customparams = {
		tonnage			= 35,
    },
}

local Prime = Adder:New{
	description         = "Light Sniper",
	weapons 		= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
		},
		[3] = {
			name	= "Flamer",
		},
	},
	customparams = {
		variant         = "Prime",
		speed			= 90,
		price			= 20830,
		heatlimit 		= 22,
		barrelrecoildist = {[1] = 5, [2] = 5},
		armor			= {type = "ferro", tons = 6},
    },
}

local B = Adder:New{
	description         = "Light Sniper",
	weapons 		= {	
		[1] = {
			name	= "LBX5",
		},
		[2] = {
			name	= "CLPL",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
	},
	customparams = {
		variant         = "B",
		speed			= 90,
		price			= 14220,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 6},
		barrelrecoildist = {[1] = 5},
		maxammo 		= {ac5 = 1},
    },
}

return lowerkeys({
	["WF_Adder_Prime"] = Prime:New(),
	["HH_Adder_Prime"] = Prime:New(),
	["GB_Adder_Prime"] = Prime:New(),
	["SJ_Adder_Prime"] = Prime:New(),
	["WF_Adder_B"] = B:New(),
	["HH_Adder_B"] = B:New(),
	["GB_Adder_B"] = B:New(),
	["JF_Adder_B"] = B:New(),
	["SJ_Adder_B"] = B:New(),
})