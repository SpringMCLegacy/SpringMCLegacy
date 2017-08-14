local Demolisher = Tank:New{
	name              	= "Demolisher",
	description         = "Heavy Brawler Tank",
	
	trackWidth			= 28,--width to render the decal
	
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "AC20",
		},
	},

	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 6090,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 12},
		maxammo 		= {ac20 = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		trackwidth		= 56,
    },
}

local Devastator = Demolisher:New{
	name              	= "Devastator",
	description         = "Heavy Brawler Tank",
	
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "AC20",
		},
		[3] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "MBL",
			maxAngleDif = 60,
		},
		[5] = {
			name	= "Flamer",
			SlaveTo = 1,
		},
	},
	customparams = {
		armor			= {type = "standard", tons = 14},
		price			= 10290,
		maxammo 		= {ac20 = 2, srm = 2},
		replaces		= "cc_demolisher",
    },
}

local DemolisherArrow = Demolisher:New{
	description         = "Heavy Artillery Support",
	
	weapons = {	
		[1] = {
			name	= "ArrowIV",
		},
		[2] = {
			name	= "ArrowIV",
		},
		[3] = {
			name	= "MBL",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "MBL",
			maxAngleDif = 60,
		},
	},
	customparams = {
		maxammo 		= {arrow = 7},
		price			= 12970,
    },
}

local DemolisherK = Demolisher:New{
	
	weapons = {	
		[1] = {
			name	= "MRM30",
		},
		[2] = {
			name	= "MRM30",
		},
		[3] = {
			name	= "MRM30",
		},
	},
	customparams = {
		price			= 12420,
		maxammo 		= {mrm = 6},
		replaces		= "dc_demolisher",
    },
}

return lowerkeys({
	["CC_Demolisher"] = Demolisher:New(),
	["CC_Devastator"] = Devastator:New(),
	["DC_Demolisher"] = Demolisher:New(),
	--["DC_DemolisherK"] = DemolisherK:New(),
	["FS_Demolisher"] = Demolisher:New(),
	["FW_Demolisher"] = Demolisher:New(),
	--["LA_Demolisher"] = Demolisher:New(),
})