local Thanatos = Heavy:New{
	name				= "Thanatos",
		
    customparams = {
		cockpitheight	= 7.7,
		tonnage			= 75,
    },
}

local TNS4S = Thanatos:New{
	description         = "Heavy Brawler",
	weapons = {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "MPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MRM30",
		},
		[4] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "ERMBL",
			SlaveTo	= 4,
			OnlyTargetCategory = "ground",
		},
	},
		
    customparams = {
		variant			= "TNS-4S",
		speed			= 80,
		price			= 18440,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 13},
		maxammo 		= {mrm = 2},
		barrelrecoildist = {[1] = 4},
		ecm 			= true,
		jumpjets		= 5,
    },
}

return lowerkeys({ 
	["FS_Thanatos_TNS4S"] = TNS4S:New(),
	["LA_Thanatos_TNS4S"] = TNS4S:New(),
})