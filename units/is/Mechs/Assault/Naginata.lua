local Naginata = Assault:New{
	name				= "Naginata",

	customparams = {
		cockpitheight	= 9,
		tonnage			= "95",
    },
}
	
local NGC3A = Naginata:New{
	description         = "Assault Missile Boat",
	weapons	= {	
		[1] = {
			name	= "ALRM15",
		},
		[2] = {
			name	= "ALRM15",
		},
		[3] = {
			name	= "ALRM15",
		},
		[4] = {
			name	= "ERPPC",
		},
	},
		
    customparams = {
		variant			= "NG-C3A",
		speed			= 50,
		price			= 19540,
		heatlimit 		= 30,
		armor			= {type = "standard", tons = 14},
		maxammo 		= {lrm = 6},
    },
}

	
return lowerkeys({ 
	["DC_Naginata_NGC3A"] = NGC3A:New(),
})