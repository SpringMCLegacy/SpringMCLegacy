local EnforcerIII = Medium:New{
	name				= "Enforcer III",
	
	customparams = {
		cockpitheight	= 11.8,
		tonnage			= 50,
    },
}

local ENF6M = EnforcerIII:New{
	description         = "Medium Vanguard",
	weapons	= {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "ERSBL",
		},
	},

	customparams = {
		variant			= "ENF-6M",
		speed			= 80,
		price			= 14600,
		heatlimit 		= 12,--12 double
		armor			= 10,
		jumpjets		= 5,
		maxammo 		= {ac10 = 2},
		mods			= {"doubleheatsinks", "endosteel", "xlengine"},
    },
}

return lowerkeys({ 
	["FS_EnforcerIII_ENF6M"] = ENF6M:New(),
})