local Saracen = Hover:New{
	name              	= "Saracen",
	
	customparams = {
		tonnage			= 35,
    },
}

local SaracenLRM = Saracen:New{
	description         = "Light Missile Support Hover",
	
	weapons 		= {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "SRM6",
		},
	},
	
	customparams = {
		variant         = "LRM",
		speed			= 120,
		price			= 6730,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 7},
		maxammo 		= {lrm = 1, srm = 1},
		squadsize 		= 1,
    },
}

local SaracenMRM = Saracen:New{
	description         = "Light Strike Hover",
	
	weapons 		= {	
		[1] = {
			name	= "MRM20",
		},
		[2] = {
			name	= "SSRM2",
		},
	},
	
	customparams = {
		variant         = "MRM",
		speed			= 120,
		price			= 2850,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 7},
		maxammo 		= {mrm = 2, srm = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["DC_SaracenLRM"] = SaracenLRM:New(),
	["DC_SaracenMRM"] = SaracenMRM:New(),
})