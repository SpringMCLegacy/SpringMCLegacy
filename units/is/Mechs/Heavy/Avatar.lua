local Avatar = Heavy:New{
	name				= "Avatar",
	
	customparams = {
		cockpitheight	= 9.4,
		tonnage			= 70,
		mods			= {"doubleheatsinks"},
		omni			= true,
	},
}

local AV1OP = Avatar:New{
	description         = "Heavy Brawler",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "LRM10",
		},
		[7] = {
			name	= "LRM10",
		},
		[8] = {
			name	= "MG",
		},
		[9] = {
			name	= "MG",
		},
	},

    customparams = {
		variant			= "AV1-O (Prime)",
		speed			= 60,
		price			= 13950,
		heatlimit 		= 13,--10 double
		armor			= 12,
		maxammo 		= {ac10 = 2, lrm = 3},
		barrelrecoildist = {[1] = 5},
		mods			= {"artemislrm", "doubleheatsinks"},
    },
}

local AV1OA = Avatar:New{
	description         = "Heavy Juggernaut",
	
	weapons 		= {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SRM6",
		},
		[6] = {
			name	= "SRM6",
		},
	},

    customparams = {
		variant			= "AV1-O (Cfg A)",
		speed			= 60,
		price			= 14810,
		heatlimit 		= 13,--10 double
		armor			= 12,
		maxammo 		= {ac20 = 3, srm = 2},
		barrelrecoildist = {[1] = 4},
		jumpjets		= 4,
    },
}

local AV1OB = Avatar:New{
	description         = "Heavy Missile Boat",
	
	weapons 		= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
		[3] = {
			name	= "LRM10",
		},
		[4] = {
			name	= "LRM10",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},

    customparams = {
		variant			= "AV1-O (Cfg B)",
		speed			= 60,
		price			= 14960,
		heatlimit 		= 13,--10 double
		armor			= 12,
		maxammo 		= {lrm = 6},
		mods			= {"artemislrm", "doubleheatsinks"},
    },
}

return lowerkeys({
	["DC_Avatar_AV1OP"] = AV1OP:New(),
	["DC_Avatar_AV1OA"] = AV1OA:New(),
	["DC_Avatar_AV1OB"] = AV1OB:New(),
})