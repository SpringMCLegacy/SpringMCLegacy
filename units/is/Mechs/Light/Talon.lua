local Talon = Light:New{
	name				= "Talon",

	customparams = {
		cockpitheight	= 4.3,
		tonnage			= 35,
    },
}

local TLN5W = Talon:New{
	description         = "Light Brawler",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant         = "TLN-5W",
		speed			= 120,
		price			= 11750,
		heatlimit 		= 15,--11 double
		armor			= 7.5,
		mods			= {"doubleheatsinks"},
    },
}

local TLN5Z = Talon:New{
	description         = "Light Sniper",
	weapons = {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERLBL",
		},
	},
		
	customparams = {
		variant         = "TLN-5Z",
		speed			= 110,
		price			= 11680,
		heatlimit 		= 13,--10 double
		armor			= 7.5,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({
	--["LA_Talon_TLN5W"] = TLN5W:New(),
	--["FS_Talon_TLN5Z"] = TLN5Z:New(),
	--["DC_Talon_TLN5Z"] = TLN5Z:New(),
})