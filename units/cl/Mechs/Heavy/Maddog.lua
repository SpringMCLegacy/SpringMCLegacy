local Maddog = Heavy:New{
	name				= "Mad Dog",
		
    customparams = {
		cockpitheight	= 55,
		tonnage			= 60,
    },
}

local Prime = Maddog:New{
	description         = "Heavy LRM Support",
	weapons = {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "CLPL",
		},
		[4] = {
			name	= "CLPL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "CMPL",
		},
	},
		
    customparams = {
		variant			= "Prime",
		speed			= 80,
		price			= 23510,
		heatlimit 		= 24,
		armor			= {type = "ferro", tons = 8.5},
		maxammo 		= {lrm = 2},
    },
}

return lowerkeys({ 
	["WF_Maddog_Prime"] = Prime:New(),
})