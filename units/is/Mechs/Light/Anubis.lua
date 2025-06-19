local Anubis = Light:New{
	name				= "Anubis",
	
	leaveTracks			= true,	
	trackType			= "Anubis",
	trackOffset			= 6,
	trackWidth			= 24,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 4,
		tonnage			= 30,
    },
}

local ABS3L = Anubis:New{
	description         = "Light Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "LRM10",
			SlaveTo	= 1,
		},
		[3] = {
			name	= "ERSBL",
		},
		[4] = {
			name	= "ERSBL",
		},
	},
	
    customparams = {
		variant         = "ABS-3L",
		speed			= 120,
		price			= 9510,
		heatlimit 		= 15,--10 double
		armor			= 5.5,
		maxammo 		= {lrm = 1},
		ecm 			= true,
		mods			= {"doubleheatsinks", "stealtharmour"},
    },
}

local ABS3T = Anubis:New{
	description         = "Light Sniper",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERMBL",
			SlaveTo	= 1,
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERSBL",
			SlaveTo	= 3,
		},
	},
	
    customparams = {
		variant         = "ABS-3T",
		speed			= 120,
		price			= 11660,
		heatlimit 		= 12,--12 double
		armor			= 5.5,
		ecm 			= true,
		mods			= {"doubleheatsinks", "stealtharmour"},
    },
}

return lowerkeys({ 
	["CC_Anubis_ABS3L"] = ABS3L:New(),
	["CC_Anubis_ABS3T"] = ABS3T:New(),
})