local Wolfhound = Light:New{
	name              	= "Wolfhound",
	
	leaveTracks			= true,	
	trackType			= "Wolfhound",
	trackOffset			= 6,
	trackWidth			= 20,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 15.27,
		tonnage 		= 35,
    },
}

local WLF2 = Wolfhound:New{
	description         = "Light Vanguard",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
			SlaveTo = 2;
		},
		[4] = {
			name	= "MBL",
			SlaveTo = 2;
		},
		[5] = {
			name	= "MBL",
			SlaveTo = 2;
		},
	},
		
	customparams = {
		variant         = "WLF-2",
		speed			= 90,
		price			= 10610,
		heatlimit 		= 10,--10 Double
		armor			= 7.5,
		mods			= {"doubleheatsinks"},
    },
}

local WLF3S = Wolfhound:New{
	description         = "Light Vanguard",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
			SlaveTo = 2;
		},
		[4] = {
			name	= "ERMBL",
			SlaveTo = 2;
		},
		[5] = {
			name	= "ERSBL",
			SlaveTo = 2;
		},
	},
		
	customparams = {
		variant         = "WLF-3S",
		speed			= 90,
		price			= 11790,
		heatlimit 		= 12,--10 Double
		armor			= 7.5,
		mods			= {"doubleheatsinks", "endosteel", "lightengine"},
    },
}

return lowerkeys({
	["LA_Wolfhound_WLF2"] = WLF2:New(),
	["FS_Wolfhound_WLF2"] = WLF2:New(),
	
	["LA_Wolfhound_WLF3S"] = WLF3S:New(),
})