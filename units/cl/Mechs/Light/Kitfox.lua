local Kitfox = Light:New{
	name				= "Kit Fox",

	customparams = {
		tonnage			= 30,
    },

}

local Prime = Kitfox:New{
	description         = "Light Multirole",
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "LBX5",
		},
		[3] = {
			name	= "CSPL",
		},
		[4] = {
			name	= "SSRM4",
		},
	},
	
	customparams = {
		variant         = "Prime",
		speed			= 90,
		price			= 10850,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {ac5 = 1, srm = 1},
    },
}

local A = Kitfox:New{
	description         = "Light Multirole",
	
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
		},
	},
	
	customparams = {
		variant         = "A",
		speed			= 90,
		price			= 13100,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {gauss = 2},
    },
}

local C = Kitfox:New{
	description         = "Light Scout",
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CSPL",
		},
		[3] = {
			name	= "CSPL",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "TAG",
		},
		[6] = {
			name	= "AMS",
		},
		[7] = {
			name	= "AMS",
		},
		[8] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		variant         = "C",
		speed			= 90,
		price			= 11470,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 4},
		bap				= true,
		ecm				= true,
    },
}

return lowerkeys({
	--["JF_Kitfox_Prime"] = Prime:New(),
	--["JF_Kitfox_A"] = A:New(),
	--["JF_Kitfox_C"] = C:New(),
})