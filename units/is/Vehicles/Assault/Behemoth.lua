local Behemoth = Tank:New{
	name              	= "Behemoth",
	description         = "Assault Tank",
	trackWidth			= 32,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "AC10",
		},
		[3] = {
			name	= "LRM20",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "SRM6",
		},
	},

	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 30,
		price			= 10000,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 18},
		maxammo 		= {ac10 = 2, lrm = 1, srm = 1},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
	},
}

return lowerkeys({
	["CC_Behemoth"] = Behemoth:New(),
})