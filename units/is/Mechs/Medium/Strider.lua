local Strider = Medium:New{
	name				= "Strider",
	
	customparams = {
		cockpitheight	= 3.1,
		tonnage			= 40,
		omni			= true,
    },
}

local SR1OP = Strider:New{
	description         = "Medium Striker",
	weapons	= {	
		[1] = {
			name	= "SRM6",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "SBL",
		},
	},

	customparams = {
		variant			= "SR1-O Prime",
		speed			= 90,
		price			= 8670,
		heatlimit 		= 10,
		armor			= 7.5,
		maxammo 		= {srm = 2},
		mods			= {"artemissrm"},
    },
}

local SR1OB = Strider:New{
	description         = "Medium Missile Boat",
	weapons	= {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "LRM10",
		},
	},

	customparams = {
		variant			= "SR1-O B",
		speed			= 90,
		price			= 9100,
		heatlimit 		= 10,
		armor			= 7.5,
		maxammo 		= {lrm = 2},
    },
}

return lowerkeys({ 
	["DC_Strider_SR1OP"] = SR1OP:New(),
	["DC_Strider_SR1OB"] = SR1OB:New(),
})