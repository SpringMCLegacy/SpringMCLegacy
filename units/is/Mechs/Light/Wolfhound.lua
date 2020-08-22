local Wolfhound = Light:New{
	name              	= "Wolfhound",
	
	customparams = {
		cockpitheight	= 8.5,
		tonnage 		= 35,
    },
}

local WLF2 = Wolfhound:New{
	description         = "Light Brawler",
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
		heatlimit 		= 13,--10 Double
		armor			= 7.5,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({
	["LA_Wolfhound_WLF2"] = WLF2:New(),
})