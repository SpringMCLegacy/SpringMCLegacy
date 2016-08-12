local Timberwolf = Heavy:New{
	name				= "Timber Wolf",
		
    customparams = {
		cockpitheight	= 55,
		tonnage			= 75,
    },
}

local Prime = Timberwolf:New{
	description         = "Heavy Skirmisher",
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "MG",
		},
		[7] = {
			name	= "MG",
		},
		[8] = {
			name	= "LRM20",
		},
		[9] = {
			name	= "LRM20",
		},
	},
		
    customparams = {
		variant			= "Prime",
		speed			= 80,
		price			= 27370,
		heatlimit 		= 34,
		armor			= {type = "ferro", tons = 12},
		maxammo 		= {ac5 = 2, lrm = 2},
		barrelrecoildist = {[1] = 4},
    },
}

return lowerkeys({ 
	["WF_Timberwolf_Prime"] = Prime:New(),
})