local Galleon = LightTank:New{
	name              	= "Galleon",
	trackWidth			= 20,
	
	customparams = {
		tonnage			= 30,
    },
}

local GAL102 = Galleon:New{
	description         = "Troop Transport",
	
	weapons	= {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
	
	customparams = {
		variant         = "GAL102",
		speed			= 90,
		price			= 1620,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["FW_Galleon_GAL102"] = GAL102:New(),
})