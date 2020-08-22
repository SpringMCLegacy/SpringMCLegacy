local Maddog = Heavy:New{
	name				= "Mad Dog",
		
    customparams = {
		cockpitheight	= 13.4,
		tonnage			= 60,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}

local Prime = Maddog:New{
	description         = "Heavy Ranged",
	weapons = {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "CLPL",
		},
		[4] = {
			name	= "CLPL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "CMPL",
		},
	},
		
    customparams = {
		variant			= "Prime",
		speed			= 80,
		price			= 23510,
		heatlimit 		= 16,
		armor			= 8.5,
		maxammo 		= {lrm = 2},
    },
}

local A = Maddog:New{
	description         = "Heavy Brawler",
	weapons = {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "LBX5",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "SRM6",
		},
		[6] = {
			name	= "SRM6",
		},
		[7] = {
			name	= "SRM6",
		},
		[8] = {
			name	= "SRM6",
		},
	},
		
    customparams = {
		variant			= "A",
		speed			= 80,
		price			= 19230,
		heatlimit 		= 16,
		armor			= 8.5,
		maxammo 		= {srm = 4, ac5 = 2},
    },
}

local D = Maddog:New{
	description         = "Heavy Ranged",
	weapons = {	
		[1] = {
			name	= "ATM12",
		},
		[2] = {
			name	= "ATM12",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "CERSBL",
		},
		[6] = {
			name	= "CERSBL",
		},
		[7] = {
			name	= "CMPL",
		},
		[8] = {
			name	= "CMPL",
		},
	},
		
    customparams = {
		variant			= "D",
		speed			= 80,
		price			= 24470,
		heatlimit 		= 16,
		armor			= 8.5,
		maxammo 		= {atm = 6},
    },
}
return lowerkeys({ 
	["WF_Maddog_Prime"] = Prime:New(),
	["WF_Maddog_D"] = D:New(),
	--["JF_Maddog_Prime"] = Prime:New(),
	--["JF_Maddog_D"] = D:New(),
	--["SJ_Maddog_Prime"] = Prime:New(),
	--["SJ_Maddog_A"] = A:New(),
	--["SF_Maddog_D"] = D:New(),
	--["GB_Maddog_Prime"] = Prime:New(),
	--["GB_Maddog_D"] = D:New(),
	--["HH_Maddog_Prime"] = Prime:New(),
	--["HH_Maddog_D"] = D:New(),
})