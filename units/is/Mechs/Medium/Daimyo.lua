local Daimyo = Medium:New{
	name				= "Daimyo",
	
	customparams = {
		cockpitheight	= 11.5,
		tonnage			= 40,
    },
}

local DMO1K = Daimyo:New{
	description         = "Medium Sniper",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
			SlaveTo = 3,
		},
	},

	customparams = {
		variant			= "DMO-1K",
		speed			= 80,
		price			= 11480,
		heatlimit 		= 15,--11 double
		armor			= 7.5,
		maxammo 		= {srm = 2},
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

return lowerkeys({ 
	["DC_Daimyo_DMO1K"] = DMO1K:New(),
})