local Firestarter = Light:New{
	name              	= "Firestarter",
	customparams = {
		cockpitheight	= 9,
		tonnage			= 35,
    },
}

local FS9S = Firestarter:New{
	description         = "Light Brawler",
	weapons = {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "Flamer",
		},
		[4] = {
			name	= "Flamer",
		},
		[5] = {
			name	= "Flamer",
		},
		[6] = {
			name	= "Flamer",
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
		price			= 7540,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5.5},
		bap 			= true,
		jumpjets		= 6,
    },
}

return lowerkeys({
	["LA_Firestarter_FS9S"] = FS9S:New(),
})