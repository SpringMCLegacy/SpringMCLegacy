local Longbow = Assault:New{
	name				= "Longbow",

	customparams = {
		cockpitheight	= 21.1,
		tonnage			= "85",
    },
}
	
local LGB12C = Longbow:New{
	description         = "Assault Missile Support",
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "LRM15",
		},
		[5] = {
			name	= "ERSBL",
		},
		[6] = {
			name	= "ERSBL",
		},
		[7] = {
			name	= "ERSBL",
		},
	},
		
    customparams = {
		variant			= "LGB-12C",
		speed			= 50,
		price			= 16860,
		heatlimit 		= 24,
		armor			= {type = "standard", tons = 12.5},
		maxammo 		= {lrm = 9},
    },
}

local LGB8V = Longbow:New{
	description         = "Assault Artillery Support",
	weapons	= {	
		[1] = {
			name	= "ArrowIV",
		},
		[2] = {
			name	= "ArrowIV",
		},
		[3] = {
			name	= "SPL",
		},
	},
		
    customparams = {
		variant			= "LGB-8V",
		speed			= 50,
		price			= 18080,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 12.5},
		maxammo 		= {arrow = 8},
    },
}
	
return lowerkeys({ 
	["CC_Longbow_LGB12C"] = LGB12C:New(),
	["FS_Longbow_LGB12C"] = LGB12C:New(),
	["FS_Longbow_LGB8V"] = LGB8V:New(),
	["LA_Longbow_LGB8V"] = LGB8V:New(),
	["FW_Longbow_LGB12C"] = LGB12C:New(),
	["FW_Longbow_LGB8V"] = LGB8V:New(),
})