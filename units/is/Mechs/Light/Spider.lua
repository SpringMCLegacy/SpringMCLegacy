local Spider = Light:New{
	name              	= "Spider",
	
	customparams = {
		cockpitheight	= 5.6,
		tonnage			= 25,
    },
}

local SDR7K = Spider:New{
	description         = "Light Scout",
	weapons = {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant         = "SDR-7K",
		speed			= 120,
		price			= 7520,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 5.5},
		jumpjets		= 8,
    },
}

local SDR7M = Spider:New{
	description         = "Light Scout",
	weapons = {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant         = "SDR-7M",
		speed			= 120,
		price			= 6210,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 3},
		jumpjets		= 8,
    },
}

return lowerkeys({
	["DC_Spider_SDR7K"] = SDR7K:New(),
	["FW_Spider_SDR7M"] = SDR7M:New(),
})