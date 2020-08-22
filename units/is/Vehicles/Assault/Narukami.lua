local Narukami = Tank:New{
	name              	= "Narukami",
	description         = "Superheavy Strike Tank",
	trackWidth			= 34,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "PPC",
		},
		[4] = {
			name	= "AMS",
		},
		[5] = {
			name	= "AMS",
		},
	},

	customparams = {
		tonnage			= 90,
		variant         = "",
		speed			= 50,
		price			= 21250,
		heatlimit 		= 20,
		armor			= 17.5,
		maxammo 		= {gauss = 2},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		--replaces		= "dc_behemoth",
	},
}

return lowerkeys({
	["DC_Narukami"] = Narukami:New(),
})