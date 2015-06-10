local Harasser = Hover:New{
	name              	= "Harasser",
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
	},
	
	customparams = {
		tonnage			= 25,
		variant         = "",
		speed			= 150,
		price			= 4130,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 1.5},
		maxammo 		= {srm = 1},
		squadsize 		= 4,
    },
}

return lowerkeys({
	["FS_Harasser"] = Harasser:New(),
	["FW_Harasser"] = Harasser:New(),
})