local Raptor = Light:New{
	name			= "Raptor",
	customparams = {
		cockpitheight	= 2.9,
		tonnage 		= 25,
    },
}

local RTX1OP = Raptor:New{
	description         = "Light Missile Support",
	weapons = {	
		[1] = {
			name	= "LRM5",
		},
		[2] = {
			name	= "LRM5",
		},
		[3] = {
			name	= "LRM5",
		},
		[4] = {
			name	= "MBL",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "SBL",
		},
		[7] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "RTX1-O Prime",
		speed			= 110,
		price			= 7210,
		heatlimit 		= 20,
		maxammo 		= {lrm = 1},
		armor			= {type = "standard", tons = 4},
    },
}

local RTX1OA = Raptor:New{
	description         = "Light Striker",
	weapons = {	
		[1] = {
			name	= "LBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "LBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "RTX1-O A",
		speed			= 110,
		price			= 7830,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 4},
    },
}

local RTX1OB = Raptor:New{
	description         = "Light Skirmisher",
	weapons = {	
		[1] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "SRM6",
		},
	},
		
	customparams = {
		variant         = "RTX1-O B",
		speed			= 110,
		price			= 6130,
		heatlimit 		= 20,
		maxammo 		= {srm = 2},
		armor			= {type = "standard", tons = 4},
    },
}

return lowerkeys({
	["DC_Raptor_RTX1OP"] = RTX1OP:New(),
	["DC_Raptor_RTX1OA"] = RTX1OA:New(),
	["DC_Raptor_RTX1OB"] = RTX1OB:New(),

})