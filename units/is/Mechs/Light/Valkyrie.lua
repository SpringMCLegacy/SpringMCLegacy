local Valkyrie = Light:New{
	name				= "Valkyrie",

	customparams = {
		tonnage			= 35,
    },
}

local VLKQD = Valkyrie:New{
	description         = "Light LRM Support",
	weapons	= {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant         = "VLKQD",
		speed			= 80,
		price			= 17000,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 6},
		jumpjets		= 5,
		maxammo 		= {lrm = 120},
    },
}

return lowerkeys({
	["FS_Valkyrie_VLKQD"] = VLKQD:New(),
})