local Hollander = Light:New{
	name				= "Hollander",
	customparams = {
		cockpitheight	= 8.5,
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
		variant         = "BZK-F3",
		speed			= 80,
		price			= 9530,
		heatlimit 		= 10,
		armor			= 4,
		maxammo 		= {gauss = 2},
		barrelrecoildist = {[1] = 5},
		mods 			= {"ferrofibrousarmour"},
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
		variant         = "BZK-G1",
		speed			= 80,
		price			= 9730,
		heatlimit 		= 10,
		armor			= 6,
		maxammo 		= {ac10 = 2},
		barrelrecoildist = {[1] = 5},
		mods 			= {"ferrofibrousarmour"},
    },	
}

return lowerkeys({ 
	["LA_Hollander_BZKF3"] = BZKF3:New(),
	["FS_Hollander_BZKG1"] = BZKG1:New(),
})