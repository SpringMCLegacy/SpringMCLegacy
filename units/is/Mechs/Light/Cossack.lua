local Cossack = Light:New{
	name              	= "Cossack",
	
	leaveTracks			= true,	
	trackType			= "Cossack",
	trackOffset			= 6,
	trackWidth			= 20,
	trackStretch 		= 2,
	customparams = {
		cockpitheight	= 12.78,
		tonnage 		= 20,
    },
}

local CSK1 = Cossack:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "C-SK1",
		speed			= 90,
		price			= 4650,
		heatlimit 		= 10,
		armor			= 3,
		maxammo 		= {srm = 1},
		jumpjets		= 6,
		mods 			= {"jumpjets", "endosteel", "xlengine"},
    },
}

return lowerkeys({
	["CC_Cossack_CSK1"] = CSK1:New(),
})