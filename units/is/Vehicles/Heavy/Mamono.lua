local Mamono = Tank:New{
	name              	= "Mamono",
	description			= "Battle Armor Transport",
	trackWidth			= 32,--width to render the decal
	transportCapacity		= 5,
	transportSize = 1,	
	
	weapons 		= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "MRM40",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MG",
			maxAngleDif = 180,
			mainDir = [[1 0 0]],
		},
		[4] = {
			name	= "MG",
			maxAngleDif = 180,
			mainDir = [[-1 0 0]],
		},
		[5] = {
			name	= "AMS",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 70,
		variant         = "",
		speed			= 60,
		price			= 14420,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 10},
		maxammo 		= {mrm = 4},
		squadsize 		= 1,
		--replaces		= "dc_heavyapc",
    },
}

return lowerkeys({
	--["DC_Mamono"] = Mamono:New(),
})