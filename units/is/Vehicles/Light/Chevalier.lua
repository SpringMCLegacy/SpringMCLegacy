local Chevalier = LightTank:New{
	name              	= "Chevalier",
	description 		= "Light Striker",
	trackWidth			= 20,
		
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "SSRM2",
		},
		[3] = {
			name	= "SSRM2",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 90,
		price			= 4440,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 6.5},
		maxammo 		= {srm = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CS_Chevalier"] = Chevalier:New(),
})