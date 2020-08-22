local Sunder = Assault:New{
	name				= "Sunder",
    customparams = {
		cockpitheight	= 5,
		tonnage			= 90,
		mods			= {"doubleheatsinks"},
		omni			= true,
    },
}

local SD1OP = Sunder:New{
	description         = "Assault Juggernaut",
	weapons 		= {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "LBL",
		},
		[3] = {
			name	= "LBL",
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
			name	= "SRM4",
		},
		[7] = {
			name	= "SRM4",
		},
		[8] = {
			name	= "SRM4",
		},
	},
    customparams = {
		variant			= "SD1-O (Prime)",
		speed			= 60,
		price			= 17470,
		heatlimit 		= 20,--15 double
		armor			= 16.5,
		maxammo 		= {ac20 = 2, srm = 2},
		barrelrecoildist = {[1] = 3},
    },
}

local SD1OA = Sunder:New{
	description         = "Assault Brawler",
	weapons 		= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "LRM5",
		},
		[6] = {
			name	= "LRM5",
		},
		[7] = {
			name	= "LRM5",
		},
	},
    customparams = {
		variant			= "SD1-O (Cfg A)",
		speed			= 60,
		price			= 20030,
		heatlimit 		= 20,--15 double
		armor			= 16.5,
		maxammo 		= {gauss = 2, lrm = 2},
		barrelrecoildist = {[1] = 3},
    },
}

local SD1OB = Sunder:New{
	description         = "Assault Missile Boat",
	weapons 		= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "SD1-O (Cfg B)",
		speed			= 60,
		price			= 15970,
		heatlimit 		= 20,--15 double
		armor			= 16.5,
		maxammo 		= {lrm = 5},
    },
}

local SD1OC = Sunder:New{
	description         = "Assault Skirmisher",
	weapons 		= {	
		[1] = {
			name	= "MRM40",
		},
		[2] = {
			name	= "MRM30",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SSRM4",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "SSRM4",
			OnlyTargetCategory = "ground",
		},
	},
    customparams = {
		variant			= "SD1-O (Cfg C)",
		speed			= 60,
		price			= 17350,
		heatlimit 		= 20,--15 double
		armor			= 16.5,
		maxammo 		= {mrm = 5, srm = 1},
    },
}

return lowerkeys({
	DC_Sunder_SD1OP = SD1OP:New(),
	DC_Sunder_SD1OA = SD1OA:New(),
	DC_Sunder_SD1OB = SD1OB:New(),
	DC_Sunder_SD1OC = SD1OC:New(),
})