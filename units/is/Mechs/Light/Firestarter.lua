local Firestarter = Light:New{
	name              	= "Firestarter",
	customparams = {
		tonnage			= 35,
    },
}

local FS9S = Firestarter:New{
	description         = "Light Skirmisher/Support",
	weapons = {	
		[1] = {
			name	= "Flamer",
		},
		[2] = {
			name	= "Flamer",
		},
		[3] = {
			name	= "Flamer",
		},
		[4] = {
			name	= "Flamer",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
		[7] = {
			name	= "SBL",
		},
		[8] = {
			name	= "AMS",
		},
	},
		
	customparams = {
		variant         = "FS-9S",
		speed			= 90,
		price			= 12000,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5.5},
		bap 			= true,
		jumpjets		= 6,
    },
}

return lowerkeys({
	["FS_Firestarter_FS9S"] = FS9S:New(),
})