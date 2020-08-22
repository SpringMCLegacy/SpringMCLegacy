local Akuma = Assault:New{
	name				= "Akuma",
	
	customparams = {
		cockpitheight	= 10,
		tonnage			= 90,
    },
}

local AKUX1 = Akuma:New{
	description         = "Assault Brawler",
	weapons = {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "ERPPC",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "SSRM4",
		},
		[6] = {
			name	= "SSRM6",
		},
		[7] = {
			name	= "MRM30",
		},
	},
		
	customparams = {
		variant			= "AKU-X1",
		speed			= 50,
		price			= 19590,
		heatlimit 		= 17,--13 double
		armor			= 17.5,
		maxammo 		= {ac10 = 2, srm = 2, mrm = 2},
		barrelrecoildist = {[1] = 5},
		mods			= {"doubleheatsinks"},
    },
}

return lowerkeys({
	--["DC_Akuma_AKUX1"] = AKUX1:New(),
})