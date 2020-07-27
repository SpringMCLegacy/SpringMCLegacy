local Longbow = Assault:New{
	name				= "Longbow",

	customparams = {
		cockpitheight	= 12,
		tonnage			= "85",
    },
}
	
local LGB7V = Longbow:New{
	description         = "Assault Missile Boat",
	weapons	= {	
		[1] = {
			name	= "ALRM20",
		},
		[2] = {
			name	= "ALRM20",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
		[6] = {
			name	= "MPL",
		},
		[7] = {
			name	= "MPL",
		},
		[8] = {
			name	= "MPL",
		},
	},
		
    customparams = {
		variant			= "LGB-7V",
		speed			= 50,
		price			= 18160,
		heatlimit 		= 28,
		armor			= {type = "standard", tons = 16},
		maxammo 		= {lrm = 6},
    },
}

local LGB12C = Longbow:New{
	description         = "Assault Missile Boat",
	weapons	= {	
		[1] = {
			name	= "ALRM20",
		},
		[2] = {
			name	= "ALRM20",
		},
		[3] = {
			name	= "ALRM15",
		},
		[4] = {
			name	= "ALRM15",
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
	description         = "Assault Missile Boat (Artillery)",
	weapons	= {	
		[1] = {
			name	= "ArrowIV",
		},
		[2] = {
			name	= "ArrowIV",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
	},
		
    customparams = {
		variant			= "LGB-8V",
		speed			= 50,
		price			= 18080,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 12.5},
		maxammo 		= {arrow = 4},
    },
}
	
return lowerkeys({ 
	["CC_Longbow_LGB7V"] = LGB7V:New(),--should be LGB-7V
	["FS_Longbow_LGB12C"] = LGB12C:New(),
	["FS_Longbow_LGB8V"] = LGB8V:New(),
	["LA_Longbow_LGB8V"] = LGB8V:New(),
	["FW_Longbow_LGB7V"] = LGB7V:New(),--should be LGB-7V
	["FW_Longbow_LGB8V"] = LGB8V:New(),
})