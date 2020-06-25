local Awesome = Assault:New{
	name				= "Awesome",

	customparams = {
		cockpitheight	= 23,
		tonnage			= "80",
    },
}
	
local AWS8Q = Awesome:New{
	description         = "Assault Striker",
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
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
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "ERPPC",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "SSRM2",
		},
		[7] = {
			name	= "SSRM2",
			OnlyTargetCategory = "ground",
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