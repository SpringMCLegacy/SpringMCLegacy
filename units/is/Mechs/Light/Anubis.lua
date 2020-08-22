local Anubis = Light:New{
	name				= "Anubis",
	customparams = {
		cockpitheight	= 4,
		tonnage			= 30,
    },
}

local ABS3L = Anubis:New{
	description         = "Light Sniper",
	weapons	= {	
		[1] = {
			name	= "LRM5",
		},
		[2] = {
			name	= "LRM5",
			SlaveTo	= 1,
		},
		[3] = {
			name	= "LRM5",
			SlaveTo	= 1,
		},
		[4] = {
			name	= "LRM5",
			SlaveTo	= 1,
		},
		[5] = {
			name	= "ERSBL",
		},
		[6] = {
			name	= "ERSBL",
			SlaveTo	= 5,
		},
	},
	
    customparams = {
		variant         = "ABS-3L",
		speed			= 120,
		price			= 9510,
		heatlimit 		= 13,--10 double
		armor			= 5.5,
		maxammo 		= {lrm = 1},
		ecm 			= true,
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({ 
	["CC_Anubis_ABS3L"] = ABS3L:New(),
})