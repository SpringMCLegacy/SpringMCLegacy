local Stormcrow = Medium:New{
	name				= "Stormcrow",
	
	customparams = {
		tonnage			= 55,
		cockpitheight	= 1.4,
		mods			= {"ferrofibrousarmour", "doubleheatsinks", "endosteel", "xlengine"},
		omni			= true,
    },
}


local A = Stormcrow:New{
	description         = "Medium Missile Boat",

	weapons = {	
		[1] = {
			name	= "ALRM20",
		},
		[2] = {
			name	= "CMPL",
		},
		[3] = {
			name	= "CMPL",
		},
		[4] = {
			name	= "CMPL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "SSRM6",
		},
		[7] = {
			name	= "SSRM6",
		},
	},

	customparams = {
		variant         = "A",
		speed			= 97,
		price			= 23190,
		heatlimit 		= 10,
		armor			= 9.5,
		maxammo 		= {lrm = 4, srm = 2},
    },
}

return lowerkeys({
	["SJ_Stormcrow_A"] = A:New(),
})