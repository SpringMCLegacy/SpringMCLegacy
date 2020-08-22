local Nacon = LightTank:New{
	name              	= "Nacon",
	trackWidth			= 16,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "ATM6",
		},
		[2] = {
			name	= "MG",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "MG",
			maxAngleDif = 60,
			SlaveTo = 2,
		},
	},
	
	customparams = {
		tonnage			= 20,
		variant         = "",
		speed			= 160,
		price			= 6900,
		heatlimit 		= 10,
		armor			= 5,
		maxammo 		= {atm = 3},
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Nacon"] = Nacon:New(),
})