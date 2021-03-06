local Vindicator = Medium:New{
	name				= "Vindicator",
	
	customparams = {
		cockpitheight	= 8,
		tonnage			= 45,
    },
}

local VND3L = Vindicator:New{
	description         = "Medium Sniper",
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
		heatlimit 		= 20,--15 double
		armor			= 9,
		jumpjets		= 4,
		maxammo 		= {lrm = 1},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["CC_Vindicator_VND3L"] = VND3L:New(),
})