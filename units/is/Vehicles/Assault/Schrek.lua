local Schrek = Tank:New{
	name              	= "Schrek",
	description         = "Sniper",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "PPC",
		},
	},
	
	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 9350,
		heatlimit 		= 30,
		armor			= {type = "standard", tons = 7},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_Schrek"] = Schrek:New(),
})