local Atlas = Assault:New{
	name				= "Atlas",
    customparams = {
		cockpitheight	= 11.3,
		tonnage			= 100,
    },
}

local AS7D = Atlas:New{
	description         = "Assault Juggernaut",
	weapons 		= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "LRM20",
		},
		[7] = {
			name	= "SRM6",
		},
	},
    customparams = {
		variant			= "AS7-D",
		speed			= 50,
		price			= 18970,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 19},
		maxammo 		= {ac20 = 2, lrm = 2, srm = 1},
		barrelrecoildist = {[1] = 5},
    },
}

local AS7K = Atlas:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "LRM20",
		},
		[7] = {
			name	= "AMS",
		},
	},
    customparams = {
		variant			= "AS7-K",
		speed			= 50,
		price			= 21750,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 19},
		maxammo 		= {gauss = 2, lrm = 2},
		barrelrecoildist = {[1] = 5},
    },
}

local AS7S = Atlas:New{
	description         = "Assault Juggernaut",
	weapons 		= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "LRM20",
		},
		[7] = {
			name	= "SRM6",
		},
		[8] = {
			name	= "SSRM4",
		},
	},
    customparams = {
		variant			= "AS7-S",
		speed			= 50,
		price			= 19290,
		heatlimit 		= 30,
		armor			= {type = "standard", tons = 19},
		maxammo 		= {ac20 = 3, lrm = 2, srm = 2},
		barrelrecoildist = {[1] = 5},
    },
}

local AS7S2 = Atlas:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "HeavyGauss",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "ALRM15",
		},
	},
    customparams = {
		variant			= "AS7-S2",
		speed			= 50,
		price			= 19290,
		heatlimit 		= 30,
		armor			= {type = "standard", tons = 19},
		maxammo 		= {hvgauss = 4, lrm = 2, srm = 2},
		ecm				= true,
		barrelrecoildist = {[1] = 5},
    },
}

return lowerkeys({
	FS_Atlas_AS7D = AS7D:New(),
	--FW_Atlas_AS7D = AS7D:New(),
	--CC_Atlas_AS7D = AS7D:New(),
	--DC_Atlas_AS7K = AS7K:New(),
	--LA_Atlas_AS7S = AS7S:New(),
	LA_Atlas_AS7S2 = AS7S2:New(),
})