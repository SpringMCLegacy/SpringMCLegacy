local DuanGung = Light:New{
	name				= "Duan Gung",

	customparams = {
		cockpitheight	= 1.15,
		tonnage			= 25,
    },
}

local D9G9 = DuanGung:New{
	description         = "Light Missile Boat",
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
		heatlimit 		= 10,--10 double
		armor			= 4,
		jumpjets		= 6,
		maxammo 		= {lrm = 1},
		mods 			= {"jumpjets", "doubleheatsinks", "endosteel", "xlengine"},
    },
}

return lowerkeys({
	["CC_DuanGung_D9G9"] = D9G9:New(),
})