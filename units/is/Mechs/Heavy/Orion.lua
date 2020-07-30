local Orion = Heavy:New{
	name				= "Orion",
	
	customparams = {
		cockpitheight	= 9.5,
		tonnage			= 75,
    },
}

local ON1MA = Orion:New{
	description         = "Heavy Striker",
	weapons = {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
		},
		[4] = {
			name	= "ALRM20",
		},
		[5] = {
			name	= "ASRM6",
		},
	},
		
	customparams = {
		variant			= "ON-1MA",
		speed			= 60,
		price			= 15020,
		heatlimit 		= 22,
		armor			= {type = "standard", tons = 14},
		maxammo 		= {ac10 = 2, lrm = 2, srm = 2},
		barrelrecoildist = {[1] = 3},
    },
}
		
local ON1MB = Orion:New{
	description         = "Heavy Brawler",
	weapons = {	
		[1] = {
			name	= "LightGauss",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "LRM20",
		},
		[5] = {
			name	= "SRM4",
		},
		[6] = {
			name	= "NARC",
		},
	},
		
	customparams = {
		variant			= "ON-1MB",
		speed			= 60,
		price			= 15020,
		heatlimit 		= 22,
		armor			= {type = "standard", tons = 14},
		maxammo 		= {ltgauss = 1, lrm = 2, srm = 2, narc = 2},
		barrelrecoildist = {[1] = 3},
    },
}

return lowerkeys({
	["FW_Orion_ON1MA"] = ON1MA:New(),
	["FW_Orion_ON1MB"] = ON1MB:New(),
})