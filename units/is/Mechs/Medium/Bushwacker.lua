local Bushwacker = Medium:New{
	name				= "Bushwacker",
	
	customparams = {
		tonnage			= 55,
    },
}

local BSWS2 = Bushwacker:New{
	description         = "Medium Striker",
	weapons = {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "ERLBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "AMS",
		},
	},
		
    customparams = {
		variant			= "BSW-S2",
		speed			= 80,
		price			= 20500,
		heatlimit 		= 22,
		armor			= {type = "ferro", tons = 9},
		maxammo 		= {srm = 4, ac10 = 2},
    },
}

local BSWX1 = Bushwacker:New{
	description         = "Medium Striker",
	weapons = {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "LRM5",
		},
		[6] = {
			name	= "LRM5",
		},
	},
		
    customparams = {
		variant			= "BSW-X1",
		speed			= 80,
		price			= 18500,
		heatlimit 		= 22,
		armor			= {type = "ferro", tons = 9},
		maxammo 		= {lrm = 1, ac10 = 1},
    },
}

return lowerkeys({
	--["FS_Bushwacker_BSWS2"] = BSWS2:New(),
	--["FS_Bushwacker_BSWX1"] = BSWX1:New(),
})