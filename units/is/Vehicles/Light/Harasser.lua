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
		armor			= 1.5,
		maxammo 		= {srm = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	--["FW_Harasser"] = Harasser:New(),
})