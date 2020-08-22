local Victor = Assault:New{
	name				= "Victor",
    customparams = {
		cockpitheight	= 12.3,
		tonnage			= 80,
    },
}

local VTR9B = Victor:New{
	description         = "Assault Juggernaut",
	weapons 		= {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-9B",
		speed			= 60,
		price			= 13780,
		heatlimit 		= 15,
		armor			= 11.5,
		maxammo 		= {ac20 = 3, srm = 1},
		barrelrecoildist = {[1] = 5},
		jumpjets		= 4,
    },
}

local VTR9D = Victor:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-9D",
		speed			= 60,
		price			= 17170,
		heatlimit 		= 15,
		armor			= 12.5,
		maxammo 		= {gauss = 2, srm = 1},
		barrelrecoildist = {[1] = 5},
		jumpjets		= 4,
    },
}

local VTR9K = Victor:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-9K",
		speed			= 60,
		price			= 17170,
		heatlimit 		= 15,
		armor			= 12.5,
		maxammo 		= {gauss = 2, srm = 1},
		barrelrecoildist = {[1] = 5},
		jumpjets		= 4,
    },
}

local VTR9S = Victor:New{
	description         = "Assault Juggernaut",
	weapons 		= {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-9S",
		speed			= 60,
		price			= 13600,
		heatlimit 		= 15,
		armor			= 10.5,
		maxammo 		= {ac20 = 3, srm = 1},
		barrelrecoildist = {[1] = 5},
		jumpjets		= 4,
    },
}

local VTR10D = Victor:New{
	description         = "Assault Juggernaut",
	weapons 		= {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "SSRM4",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-10D",
		speed			= 60,
		price			= 18940,
		heatlimit 		= 16,--12 double
		armor			= 13,
		maxammo 		= {ac20 = 6, srm = 1},
		barrelrecoildist = {[1] = 5},
		jumpjets		= 4,
		mods			= {"doubleheatsinks"},
    },
}

local VTR10L = Victor:New{
	description         = "Assault Sniper",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-10L",
		speed			= 60,
		price			= 23200,
		heatlimit 		= 16,--12 double
		armor			= 15.5,
		maxammo 		= {gauss = 3, srm = 1},
		barrelrecoildist = {[1] = 5},
		ecm 			= true,
		jumpjets		= 4,
		mods			= {"doubleheatsinks"}, --"stealtharmour"
    },
}

local VTR11D = Victor:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERLBL",
		},
		[4] = {
			name	= "SSRM4",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "VTR-11D",
		speed			= 60,
		price			= 20210,
		heatlimit 		= 20, --15 double
		armor			= 14.5,
		maxammo 		= {ac5 = 3, srm = 1},
		barrelrecoildist = {[1] = 5},
		jumpjets		= 4,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({
	CC_Victor_VTR9B = VTR9B:New(),
	CC_Victor_VTR10L = VTR10L:New(),
	--DC_Victor_VTR9B = VTR9B:New(),
	--DC_Victor_VTR9K = VTR9K:New(),
	FS_Victor_VTR9B = VTR9B:New(),
	--FS_Victor_VTR9D = VTR9D:New(),
	--FS_Victor_VTR10D = VTR10D:New(),
	FS_Victor_VTR11D = VTR11D:New(),
	LA_Victor_VTR9S = VTR9S:New(),
})