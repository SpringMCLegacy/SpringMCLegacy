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
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "ERPPC",
		},
	},
		
    customparams = {
		variant			= "NG-C3A",
		speed			= 50,
		price			= 19540,
		heatlimit 		= 20,--15 double
		armor			= 14,
		maxammo 		= {lrm = 6},
		mods			= {"artemislrm", "doubleheatsinks"},
    },
}

	
return lowerkeys({ 
	["DC_Naginata_NGC3A"] = NGC3A:New(),
})