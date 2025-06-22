local Archer = Heavy:New{
	name				= "Archer",
	
	leaveTracks			= true,	
	trackType			= "Archer",
	trackOffset			= 6,
	trackWidth			= 32,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 11,
		tonnage			= 70,
    },
}

local ARC2R = Archer:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
			SlaveTo = 1,
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
			SlaveTo = 5,
		},
	},
		
	customparams = {
		variant			= "ARC-2R",
		speed			= 60,
		price			= 14770,
		heatlimit 		= 10,
		armor			= 13,
		maxammo 		= {lrm = 4},
    },
}

local ARC2K = Archer:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LBL",
		},
		[4] = {
			name	= "LBL",
		},
	},
		
	customparams = {
		variant			= "ARC-2K",
		speed			= 60,
		price			= 13560,
		heatlimit 		= 12,
		armor			= 11,
		maxammo 		= {lrm = 4},
    },
}

local ARC4M = Archer:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
			SlaveTo = 1,
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
			SlaveTo = 5,
		},
	},
		
	customparams = {
		variant			= "ARC-4M",
		speed			= 60,
		price			= 13680,
		heatlimit 		= 1, --10 double
		armor			= 13.5,
		maxammo 		= {lrm = 4},
		mods			= {"artemislrm", "doubleheatsinks"},
    },
}

local ARC5S = Archer:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
			SlaveTo = 1,
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
			SlaveTo = 5,
		},
		[7] = {
			name	= "SSRM2",
			SlaveTo = 3,
		},
		[8] = {
			name	= "SSRM2",
			SlaveTo = 4,
		},
		[9] = {
			name	= "NARC",
		},
	},
		
	customparams = {
		variant			= "ARC-5S",
		speed			= 60,
		price			= 13530,
		heatlimit 		= 10,--10 double
		armor			= 13,
		maxammo 		= {lrm = 4, narc = 1, srm = 1},
		mods			= {"doubleheatsinks"},
    },
}

local ARC7L = Archer:New{
	description         = "Heavy Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
			SlaveTo = 1,
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
	},
		
	customparams = {
		variant			= "ARC-7L",
		speed			= 60,
		price			= 19200,
		heatlimit 		= 12, --12 double
		armor			= 13.5,
		maxammo 		= {lrm = 6},
		ecm				= true,
		mods			= {"doubleheatsinks", "stealtharmour"},
    },
}

return lowerkeys({
	["CC_Archer_ARC2R"] = ARC2R:New(),
	["DC_Archer_ARC2R"] = ARC2R:New(),
	["FS_Archer_ARC2R"] = ARC2R:New(),
	["LA_Archer_ARC2R"] = ARC2R:New(),
	
	["DC_Archer_ARC2K"] = ARC2K:New(),
	["FW_Archer_ARC4M"] = ARC4M:New(),
	["LA_Archer_ARC5S"] = ARC5S:New(),
	["CC_Archer_ARC7L"] = ARC7L:New(),
})