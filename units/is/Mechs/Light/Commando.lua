local Commando = Light:New{
	name              	= "Commando",
	
	leaveTracks			= true,	
	trackType			= "Commando",
	trackOffset			= 6,
	trackWidth			= 20,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 15.61,
		tonnage 		= 25,
    },
}

local COM1D = Commando:New{
	description         = "Light Sniper",
	weapons	= {	
		[1] = {
			name	= "LBL",
		},
		[2] = {
			name	= "SRM6",
		},
	},
		
	customparams = {
		variant         = "COM-2D",
		speed			= 90,
		price			= 5580,
		heatlimit 		= 10,
		armor			= 3,
		maxammo 		= {srm = 1},
    },
}

local COM2D = Commando:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "COM-2D",
		speed			= 90,
		price			= 5410,
		heatlimit 		= 10,
		armor			= 4,
		maxammo 		= {srm = 2},
    },
}

local COM5S = Commando:New{
	description         = "Light Skirmisher",
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
		mods 			= {"artemissrm", "ferrofibrousarmour", "endosteel", "case"},
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
			SlaveTo = 3,
		},
	},
		
	customparams = {
		variant         = "COM-7S",
		speed			= 90,
		price			= 5580,--6580
		heatlimit 		= 10, --10 double
		armor			= 3.5,
		maxammo 		= {srm = 2},
		mods 			= {"artemissrm", "doubleheatsinks", "endosteel", "case", "lightengine"},
    },
}

return lowerkeys({
	["LA_Commando_COM1D"] = COM1D:New(),
	["LA_Commando_COM2D"] = COM2D:New(),
	["LA_Commando_COM5S"] = COM5S:New(),
	["LA_Commando_COM7S"] = COM7S:New(),
})