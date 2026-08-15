local ShaYu = Medium:New{
	name				= "Sha Yu",
	
	leaveTracks			= true,	
	trackType			= "Shayu",
	trackOffset			= 6,
	trackWidth			= 26,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 5.1,
		tonnage			= 40,
    },
}

local SYU2B = ShaYu:New{
	description         = "Medium Sniper",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "TAG",
		},
	},

	customparams = {
		variant			= "SYU-2B",
		speed			= 110,
		price			= 14880,
		heatlimit 		= 13,--13 double
		armor			= 6.5,
		ecm				= true,
		mods			= {"guardian", "doubleheatsinks", "stealtharmour", "endosteel", "xlengine"},
    },
}

return lowerkeys({ 
	["CC_ShaYu_SYU2B"] = SYU2B:New(),
})