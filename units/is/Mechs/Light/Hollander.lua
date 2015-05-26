local Hollander = Light:New{
	name				= "Hollander",
	customparams = {
		tonnage			= 35,
    },
}

local BZKF3 = Hollander:New{
	description         = "Light Sniper",
	weapons	= {	
		[1] = {
			name	= "Gauss",
			OnlyTargetCategory = "ground",
		},
	},
	
    customparams = {
		variant         = "BZKF3",
		speed			= 80,
		price			= 14900,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {gauss = 2},
    },
}

local BZKG1 = Hollander:New{
	description         = "Light Brawler",
	weapons = {	
		[1] = {
			name	= "LBX10",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
	
	customparams = {
		variant         = "BZKG1",
		speed			= 80,
		price			= 13000,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 6},
		maxammo 		= {ac10 = 2},
    },	
}

return lowerkeys({ 
	["LA_Hollander_BZKF3"] = BZKF3:New(),
	["FS_Hollander_BZKG1"] = BZKG1:New(),
})