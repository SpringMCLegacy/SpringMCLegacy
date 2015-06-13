local Myrmidon = LightTank:New{
	name              	= "Myrmidon",
	description			= "Medium Sniper",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "SRM6",
		},
	},
	
	customparams = {
		tonnage			= 40,
		variant         = "",
		speed			= 80,
		price			= 4920,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5},
		maxammo 		= {srm = 1},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["LA_Myrmidon"] = Myrmidon:New(),
})