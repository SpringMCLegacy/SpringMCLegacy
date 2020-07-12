local DuanGung = Light:New{
	name				= "Duan Gung",

	customparams = {
		cockpitheight	= 1.15,
		tonnage			= 25,
    },
}

local D9G9 = DuanGung:New{
	description         = "Light Ranged",
	weapons	= {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "D9-G9",
		speed			= 110,
		price			= 7370,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4},
		jumpjets		= 6,
		maxammo 		= {lrm = 1},
    },
}

return lowerkeys({
	["CC_DuanGung_D9G9"] = D9G9:New(),
})