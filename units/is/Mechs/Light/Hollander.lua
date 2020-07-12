local Hollander = Light:New{
	name				= "Hollander",
	customparams = {
		cockpitheight	= 8.5,
		tonnage			= 35,
    },
}

local BZKF3 = Hollander:New{
	description         = "Light Ranged",
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
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {gauss = 2},
		barrelrecoildist = {[1] = 5},
    },
}

local BZKG1 = Hollander:New{
	description         = "Light Multirole",
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
		price			= 8730,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 6},
		maxammo 		= {ac10 = 2},
		barrelrecoildist = {[1] = 5}
    },	
}

return lowerkeys({ 
	["LA_Hollander_BZKF3"] = BZKF3:New(),
	["FS_Hollander_BZKG1"] = BZKG1:New(),
})