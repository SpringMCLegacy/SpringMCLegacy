local Archer = Heavy:New{
	name				= "Archer",
	
	customparams = {
		cockpitheight	= 11,
		tonnage			= 70,
    },
}
	
local ARC2R = Archer:New{
	description         = "Heavy Missile Support",
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "ARC-2R",
		speed			= 60,
		price			= 14770,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 13},
		maxammo 		= {lrm = 4},
    },
}

local ARC5S = Archer:New{
	description         = "Heavy Missile Support",
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
		[3] = {
			name	= "MPL",
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
			name	= "SSRM2",
			SlaveTo = 5,
		},
		[8] = {
			name	= "SSRM2",
			SlaveTo = 6,
		},
		[9] = {
			name	= "NARC",
		},
	},
		
	customparams = {
		variant			= "ARC-5S",
		speed			= 60,
		price			= 13530,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 13},
		maxammo 		= {lrm = 4, narc = 1, srm = 1},
    },
}

local ARC4M = Archer:New{
	description         = "Heavy Missile Support",
	weapons	= {	
		[1] = {
			name	= "ALRM20",
		},
		[2] = {
			name	= "ALRM20",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "CPLT-C3",
		speed			= 60,
		price			= 13680,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 13.5},
		maxammo 		= {lrm = 4},
    },
}

return lowerkeys({
	["LA_Archer_ARC5S"] = ARC5S:New(),
	["FS_Archer_ARC2R"] = ARC2R:New(),
	["FW_Archer_ARC4M"] = ARC4M:New(),
})