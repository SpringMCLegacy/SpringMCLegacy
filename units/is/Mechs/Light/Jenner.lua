local Jenner = Light:New{
	name              	= "Jenner",
	
	leaveTracks			= true,	
	trackType			= "Jenner",
	trackOffset			= 6,
	trackWidth			= 24,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 7.90,
		tonnage 		= 35,
    },
}

local JR7K = Jenner:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
			SlaveTo = 3,
		},
		[5] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant         = "JR7-K",
		speed			= 110,
		price			= 8890,
		heatlimit 		= 10, --10 single
		armor			= 3.5,
		maxammo 		= {srm = 1},
		jumpjets		= 5,
		mods 			= {"jumpjets", "ferrofibrousarmour", "case"},
    },
}

return lowerkeys({
	["DC_Jenner_JR7K"] = JR7K:New(),
})