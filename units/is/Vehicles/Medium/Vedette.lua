local Vedette = LightTank:New{
	name              	= "Vedette",
	trackWidth			= 23,--width to render the decal
	
	customparams = {
		tonnage			= 50,
    },
}

local VedetteUAC = Vedette:New{
	description         = "Medium Striker Tank",
	
	weapons	= {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
	},
	
	customparams = {
		variant         = "UAC",
		speed			= 80,
		price			= 4080,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 5},
		maxammo 		= {ac5 = 4},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 2,
    },
}

local VedetteLBX = Vedette:New{
	description         = "Medium Striker Tank",
	
	weapons	= {	
		[1] = {
			name	= "LBX5",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
	},
	
	customparams = {
		variant         = "LBX",
		speed			= 80,
		price			= 4080,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 5},
		maxammo 		= {ac5 = 4},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 2,
    },
}

local VedetteLG = Vedette:New{
	description         = "Medium Sniper Tank",
	
	weapons	= {	
		[1] = {
			name	= "LightGauss",
		},
	},
	
	customparams = {
		variant         = "LG",
		speed			= 80,
		price			= 10280,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {ltgauss = 4},
		barrelrecoildist = {[1] = 7},
		squadsize 		= 1,
    },
}
	
return lowerkeys({
	["FS_Vedette"] = VedetteUAC:New(),
	["LA_Vedette"] = VedetteUAC:New(),
	["CC_Vedette"] = VedetteLBX:New(),
	["FW_Vedette"] = VedetteLG:New(),
})