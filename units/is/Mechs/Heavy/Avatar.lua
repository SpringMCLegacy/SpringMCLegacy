local Avatar = Heavy:New{
	name				= "Avatar",
	
	customparams = {
		tonnage			= 70,
	},
}

local AV1OP = Avatar:New{
	description         = "Heavy Striker",
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
			name	= "ALRM10",
		},
		[7] = {
			name	= "ALRM10",
		},
		[8] = {
			name	= "MG",
		},
		[9] = {
			name	= "MG",
		},
	},

    customparams = {
		variant			= "AV1-O Prime",
		speed			= 60,
		price			= 13950,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 12},
		maxammo 		= {ac10 = 2, lrm = 3},
		barrelrecoildist = {[1] = 5},
    },
}

local AV1OA = Avatar:New{
	description         = "Heavy Brawler",
	
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
		variant			= "AV1-O A",
		speed			= 60,
		price			= 14810,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 12},
		maxammo 		= {ac20 = 3, srm = 2},
		barrelrecoildist = {[1] = 4},
		jumpjets		= 4,
    },
}

return lowerkeys({
	["DC_Avatar_AV1OP"] = AV1OP:New(),
	["DC_Avatar_AV1OA"] = AV1OA:New(),
})