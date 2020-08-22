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
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
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
		heatlimit 		= 19,--14 double
		armor			= 16,
		maxammo 		= {lrm = 6},
		mods			= {"artemislrm", "doubleheatsinks"},
    },
}

local LGB12C = Longbow:New{
	description         = "Assault Missile Boat",
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
		heatlimit 		= 16,--12 double
		armor			= 12.5,
		maxammo 		= {lrm = 9},
		mods			= {"artemislrm", "doubleheatsinks"},
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
		heatlimit 		= 11,--16 double
		armor			= 12.5,
		maxammo 		= {arrow = 4},
		mods			= {"doubleheatsinks"},
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