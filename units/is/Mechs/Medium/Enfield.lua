local Enfield = Medium:New{
	name				= "Enfield",
	
	customparams = {
		cockpitheight	= 9,
		tonnage			= 50,
    },
}

local END6Q = Enfield:New{
	description         = "Medium Vanguard",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "LPL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "SBL",
		},
	},

	customparams = {
		variant			= "END-6Q",
		speed			= 80,
		price			= 12480,
		heatlimit 		= 11,--11 double
		armor			= 11,
		maxammo 		= {ac10 = 2},
		mods			= {"doubleheatsinks", "endosteel", "xlengine", "case"},
    },
}

return lowerkeys({ 
	["LA_Enfield_END6Q"] = END6Q:New(),
})