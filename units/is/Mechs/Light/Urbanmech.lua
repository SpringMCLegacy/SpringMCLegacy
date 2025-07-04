local Urbanmech = Light:New{
	name              	= "Urbanmech",
	
	leaveTracks			= true,	
	trackType			= "Urbanmech",
	trackOffset			= 6,
	trackWidth			= 24,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 8,
		tonnage			= 30,
		torsoturnspeed	= 210,
		mods 			= {"jumpjets"},
    },
}

local UMR60 = Urbanmech:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "UM-R60",
		speed			= 30,
		price			= 5040,
		heatlimit 		= 11,
		armor			= 6,
		jumpjets		= 2,
		maxammo 		= {ac10 = 1},
		barrelrecoildist = {[1] = 4},
    },
}

local UMR60L = Urbanmech:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "UM-R60L",
		speed			= 30,
		price			= 4700,
		heatlimit 		= 11,
		armor			= 4,
		jumpjets		= 2,
		maxammo 		= {ac20 = 1},
		barrelrecoildist = {[1] = 4},
    },
}

local UMR63 = Urbanmech:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "SBL",
		},
		[3] = {
			name	= "SPL",
		},
	},
		
	customparams = {
		variant         = "UM-R63",
		speed			= 30,
		price			= 5400,
		heatlimit 		= 11,
		armor			= 6,
		jumpjets		= 2,
		maxammo 		= {ac10 = 1},
		barrelrecoildist = {[1] = 4},
    },
}

local UMR68 = Urbanmech:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "MRM30",
		},
		[2] = {
			name	= "SBL",
		},
		[3] = {
			name	= "SPL",
		},
	},
		
	customparams = {
		variant         = "UM-R68",
		speed			= 30,
		price			= 5610,
		heatlimit 		= 11,
		armor			= 6,
		jumpjets		= 2,
		maxammo 		= {mrm = 2},
    },
}

local UMR69 = Urbanmech:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "ERSBL",
		},
		[3] = {
			name	= "SPL",
		},
	},
		
	customparams = {
		variant         = "UM-R69",
		speed			= 30,
		price			= 5890,
		heatlimit 		= 10,
		armor			= 5,
		jumpjets		= 2,
		maxammo 		= {ac10 = 1},
		mods 			= {"ferrofibrousarmour"},
    },
}

local UMR70 = Urbanmech:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERSBL",
		},
	},
		
	customparams = {
		variant         = "UM-R70",
		speed			= 30,
		price			= 7240,
		heatlimit 		= 11,
		armor			= 6,
		jumpjets		= 2,
		maxammo 		= {ac5 = 2},
		mods 			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["CC_Urbanmech_UMR60"] = UMR60:New(),
	["DC_Urbanmech_UMR60"] = UMR60:New(),
	["FS_Urbanmech_UMR60"] = UMR60:New(),
	["FW_Urbanmech_UMR60"] = UMR60:New(),
	["LA_Urbanmech_UMR60"] = UMR60:New(),
	
	["CC_Urbanmech_UMR60L"] = UMR60L:New(),
	["CC_Urbanmech_UMR63"] = UMR63:New(),
	["FS_Urbanmech_UMR70"] = UMR70:New(),
	["FW_Urbanmech_UMR69"] = UMR69:New(),
	["DC_Urbanmech_UMR68"] = UMR68:New(),
})