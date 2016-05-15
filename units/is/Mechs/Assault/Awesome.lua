local Awesome = Assault:New{
	name				= "Awesome",

	customparams = {
		cockpitheight	= 64,
		tonnage			= "80",
    },
}
	
local AWS8Q = Awesome:New{
	description         = "Assault Sniper",
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "PPC",
		},
		[4] = {
			name	= "SBL",
		},
	},
		
    customparams = {
		variant			= "AWS-8Q",
		speed			= 50,
		price			= 16050,
		heatlimit 		= 28,
		armor			= {type = "standard", tons = 15},
    },
}

local AWS9M = Awesome:New{
	description         = "Assault Striker",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "ERPPC",
		},
		[4] = {
			name	= "SBL",
		},
		[5] = {
			name	= "MPL",
		},
		[6] = {
			name	= "SSRM2",
		},
		[7] = {
			name	= "SSRM2",
		},
	},
		
    customparams = {
		variant			= "AWS-9M",
		speed			= 60,
		price			= 18120,
		heatlimit 		= 40,
		armor			= {type = "standard", tons = 15.5},
		maxammo 		= {srm = 1},
    },
}
	
return lowerkeys({ 
	["CC_Awesome_AWS8Q"] = AWS8Q:New(),
	["DC_Awesome_AWS8Q"] = AWS8Q:New(),
	["FS_Awesome_AWS8Q"] = AWS8Q:New(),
	["LA_Awesome_AWS8Q"] = AWS8Q:New(),
	["FW_Awesome_AWS9M"] = AWS9M:New(),
})