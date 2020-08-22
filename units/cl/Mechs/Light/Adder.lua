local Adder = Light:New{
	name				= "Adder",

    customparams = {
		tonnage			= 35,
		cockpitheight	= 4.6,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}

local Prime = Adder:New{
	description         = "Light Ranged",
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
		heatlimit 		= 15,--11 double
		barrelrecoildist = {[1] = 5, [2] = 5},
		armor			= 6,
		mods			= {"ferrofibrousarmour", "doubleheatsinks", "targetingcomputer"},
    },
}

local A = Adder:New{
	description         = "Light Ranged",
	weapons 		= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "Flamer",
		},
		[4] = {
			name	= "CSPL",
		},
		[5] = {
			name	= "CSPL",
		},
	},
	customparams = {
		variant         = "A",
		speed			= 90,
		price			= 14370,
		heatlimit 		= 13,--10 double
		armor			= 6,
		maxammo 		= {lrm = 4},
    },
}

local B = Adder:New{
	description         = "Light Multirole",
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
		heatlimit 		= 13,--10 double
		armor			= 6,
		barrelrecoildist = {[1] = 5},
		maxammo 		= {ac5 = 1},
    },
}

return lowerkeys({
	["WF_Adder_Prime"] = Prime:New(),
	--["HH_Adder_Prime"] = Prime:New(),
	--["GB_Adder_Prime"] = Prime:New(),
	--["SJ_Adder_Prime"] = Prime:New(),
	["WF_Adder_A"] = A:New(),
	--["HH_Adder_A"] = A:New(),
	--["GB_Adder_A"] = A:New(),
	--["SJ_Adder_A"] = A:New(),
	["WF_Adder_B"] = B:New(),
	--["HH_Adder_B"] = B:New(),
	--["GB_Adder_B"] = B:New(),
	--["JF_Adder_B"] = B:New(),
	--["SJ_Adder_B"] = B:New(),
})