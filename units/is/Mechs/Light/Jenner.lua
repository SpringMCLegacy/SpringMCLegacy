local Jenner = Light:New{
	name              	= "Jenner",
	customparams = {
		cockpitheight	= 3.9,
		tonnage 		= 35,
    },
}

local JR7K = Jenner:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SRM4",
		},
	},
		
	customparams = {
		variant         = "JR7-K",
		speed			= 110,
		price			= 8890,
		heatlimit 		= 10,
		armor			= 3.5,
		maxammo 		= {srm = 1},
		jumpjets		= 5,
		mods 			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	--["DC_Jenner_JR7K"] = JR7K:New(),
})