local Cougar = Light:New{
	name				= "Cougar",

	customparams = {
		tonnage			= 35,
		cockpitheight	= 7.2,
		mods			= {"ferrofibrousarmour", "doubleheatsinks", "endosteel", "xlengine"},
		omni			= true,
    },
}
	
local Prime = Cougar:New{
	description         = "Light Generalist",
	
	weapons 		= {	
		[1] = {
			name	= "CLPL",
		},
		[2] = {
			name	= "CLPL",
		},
		[3] = {
			name	= "LRM10",
		},
		[4] = {
			name	= "LRM10",
		},
	},
	
	customparams = {
		variant         = "Prime",
		speed			= 80,
		price			= 14850,
		heatlimit 		= 10,--10 double
		armor			= 5.5,
		maxammo 		= {lrm = 2},
    },
}

local A = Cougar:New{
	description         = "Light Missile Boat",
	
	weapons 		= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "CSPL",
		},
	},
	
	customparams = {
		variant         = "A",
		speed			= 80,
		price			= 16970,
		heatlimit 		= 10,
		armor			= 5.5,
		maxammo 		= {lrm = 4},
    },
}

local B = Cougar:New{
	description         = "Light Sniper",
	
	weapons 		= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
		},
		[3] = {
			name	= "CERMBL",
		},
	},
	
	customparams = {
		variant         = "B",
		speed			= 80,
		price			= 16970,
		heatlimit 		= 16,--16 double
		armor			= 5.5,
		barrelrecoildist = {[1] = 5, [2] = 5},
    },
}

return lowerkeys({
	--["WF_Cougar_Prime"] = Prime:New(),
	--["WF_Cougar_A"] = A:New(),
	--["WF_Cougar_B"] = B:New(),
})