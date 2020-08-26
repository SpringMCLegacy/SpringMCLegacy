local ShaYu = Medium:New{
	name				= "Sha Yu",
	
	customparams = {
		cockpitheight	= 5.1,
		tonnage			= 40,
    },
}

local SYU2B = ShaYu:New{
	description         = "Medium Scout",
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
		heatlimit 		= 17,--13 double
		armor			= 6.5,
		ecm				= true,
		mods			= {"doubleheatsinks", "stealtharmour"},
    },
}

return lowerkeys({ 
	["CC_ShaYu_SYU2B"] = SYU2B:New(),
})