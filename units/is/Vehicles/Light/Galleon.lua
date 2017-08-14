local Galleon = LightTank:New{
	name              	= "Galleon",
	description			= "Light Striker Tank",
	trackWidth			= 18,
		
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "SBL",
			mainDir = [[1 0 1]],
			maxAngleDif = 100,
		},
		[3] = {
			name	= "SBL",
			mainDir = [[-1 0 1]],
			maxAngleDif = 100,
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "GAL-100",
		speed			= 90,
		price			= 3090,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["FW_Galleon"] = Galleon:New(),
})