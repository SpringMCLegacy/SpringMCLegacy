local Commando = Light:New{
	name              	= "Commando",
	
	customparams = {
		cockpitheight	= 7.1,
		tonnage 		= 25,
    },
}

local COM3A = Commando:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "Flamer",
		},
	},
		
	customparams = {
		variant         = "COM-3A",
		speed			= 90,
		price			= 5400,
		heatlimit 		= 10,
		armor			= 3,
		maxammo 		= {srm = 2},
    },
}

local COM5S = Commando:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SSRM2",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "COM-5S",
		speed			= 90,
		price			= 5570,
		heatlimit 		= 10,
		armor			= 3,
		maxammo 		= {srm = 2},
		mods 			= {"artemissrm", "ferrofibrousarmour"},
    },
}

local COM7S = Commando:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "SRM4",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "COM-7S",
		speed			= 90,
		price			= 5580,--6580
		heatlimit 		= 13,--10 double
		armor			= 3.5,
		maxammo 		= {srm = 2},
		mods 			= {"artemissrm", "doubleheatsinks"},
    },
}

return lowerkeys({
	--["LA_Commando_COM3A"] = COM3A:New(),
	--["LA_Commando_COM5S"] = COM5S:New(),
	["LA_Commando_COM7S"] = COM7S:New(),
})