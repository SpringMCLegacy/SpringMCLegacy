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
		armor			= {type = "ferro", tons = 6},
    },
}

local B = Adder:New{
	description         = "Light Sniper",
	weapons 		= {	
		[1] = {
			name	= "CLPL",
		},
		[2] = {
			name	= "LBX5",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "Flamer",
		},
	},
	customparams = {
		variant         = "B",
		speed			= 90,
		price			= 14220,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 6},
		maxammo 		= {ac5 = 1},
    },
}

return lowerkeys({
	["HH_Adder_Prime"] = Prime:New(),
	["GB_Adder_Prime"] = Prime:New(),
	["JF_Adder_Prime"] = Prime:New(),
	["SJ_Adder_Prime"] = Prime:New(),
	["WF_Adder_B"] = B:New(),
})