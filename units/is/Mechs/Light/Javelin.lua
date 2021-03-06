local Javelin = Light:New{
	name              	= "Javelin",
	customparams = {
		cockpitheight	= 5.3,
		tonnage 		= 30,
    },
}

local JVN11B = Javelin:New{
	description         = "Light Scout",
	weapons	= {	
		[1] = {
			name	= "SRM4",
		},
		[2] = {
			name	= "SRM4",
		},
	},
		
	customparams = {
		variant         = "JVN-11B",
		speed			= 90,
		price			= 6780,
		heatlimit 		= 13,--10 double
		armor			= 5,
		bap 			= true,
		ecm				= true,
		maxammo 		= {srm = 2},
		mods 			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

local JVN10P = Javelin:New{
	description         = "Light Striker",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SSRM4",
		},
	},
		
	customparams = {
		variant         = "JVN-10P",
		speed			= 90,
		price			= 5900,
		heatlimit 		= 13,--10 double
		armor			= 5,
		jumpjets		= 6,
		maxammo 		= {srm = 2},
		mods 			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

return lowerkeys({
	["FS_Javelin_JVN11B"] = JVN11B:New(),
	--["FS_Javelin_JVN10P"] = JVN10P:New(),
})