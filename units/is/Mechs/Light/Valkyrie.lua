local Valkyrie = Light:New{
	name				= "Valkyrie",

	customparams = {
		cockpitheight	= 9,
		tonnage			= 35,
    },
}

local VLKQD = Valkyrie:New{
	description         = "Light Missile Boat",
	weapons	= {	
		[1] = {
			name	= "ALRM10",
		},
		[2] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		variant         = "VLK-QD",
		speed			= 80,
		price			= 8070,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 6},
		jumpjets		= 5,
		maxammo 		= {lrm = 1},
    },
}

return lowerkeys({
	["FS_Valkyrie_VLKQD"] = VLKQD:New(),
})