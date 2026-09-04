local Vindicator = Medium:New{
	name				= "Vindicator",
	
	leaveTracks			= true,	
	trackType			= "Vindicator",
	trackOffset			= 6,
	trackWidth			= 26,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 8,
		tonnage			= 45,
    },
}

local VND3L = Vindicator:New{
	description         = "Medium Vanguard",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "LRM5",
		},
		[3] = {
			name	= "MPL",
		},
	},

	customparams = {
		variant			= "VND-3L",
		speed			= 60,
		price			= 11050,
		heatlimit 		= 15,--15 double
		armor			= 9,
		jumpjets		= 4,
		maxammo 		= {lrm = 1},
		mods			= {"jumpjets", "doubleheatsinks", "case"},
    },
}

return lowerkeys({ 
	["CC_Vindicator_VND3L"] = VND3L:New(),
})