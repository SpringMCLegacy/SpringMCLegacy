local Wolfhound = Light:New{
	name              	= "Wolfhound",
	customparams = {
		tonnage 		= 35,
    },
}

local WLF2 = Wolfhound:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "MBL",
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
	},
		
	customparams = {
		variant         = "WLF-2",
		speed			= 90,
		price			= 10610,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 7.5},
    },
}

return lowerkeys({
	["LA_Wolfhound_WLF2"] = WLF2:New(),
})