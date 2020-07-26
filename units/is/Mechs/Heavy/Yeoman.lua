local Yeoman = Heavy:New{
	name				= "Yeoman",
		
    customparams = {
		cockpitheight	= 6.5,
		tonnage			= 60,
    },
}

local YMN6Y = Yeoman:New{
	description         = "Heavy Missile Boat",
	weapons = {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM10",
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "LRM10",
		},
	},
		
    customparams = {
		variant			= "YMN-6Y",
		speed			= 60,
		price			= 13440,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 8.5},
		maxammo 		= {lrm = 6},
    },
}

return lowerkeys({ 
	["FW_Yeoman_YMN6Y"] = YMN6Y:New(),
})