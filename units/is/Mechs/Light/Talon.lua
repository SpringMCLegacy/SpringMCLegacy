local Talon = Light:New{
	name				= "Talon",

	customparams = {
		cockpitheight	= 38,
		tonnage			= 35,
    },
}

local TLN5W = Talon:New{
	description         = "Light Sniper",
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
		heatlimit 		= 22,
		armor			= {type = "standard", tons = 7.5},
    },
}

local TLN5Z = Talon:New{
	description         = "Light Striker",
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
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 7.5},
    },
}

return lowerkeys({
	["LA_Talon_TLN5W"] = TLN5W:New(),
	["FS_Talon_TLN5Z"] = TLN5Z:New(),
	["DC_Talon_TLN5Z"] = TLN5Z:New(),
})