local Razorback = Light:New{
	name              	= "Razorback",
	
	customparams = {
		cockpitheight	= 7,
		tonnage			= 30,
    },
}

local RZK9S = Razorback:New{
	description         = "Light Striker",
	weapons = {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "MG",
		},
		[6] = {
			name	= "MG",
		},
	},
		
	customparams = {
		variant         = "RZK-9S",
		speed			= 90,
		price			= 8550,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 6},
		maxammo 		= {srm = 1},
    },
}

return lowerkeys({
	["LA_Razorback_RZK9S"] = RZK9S:New(),
})