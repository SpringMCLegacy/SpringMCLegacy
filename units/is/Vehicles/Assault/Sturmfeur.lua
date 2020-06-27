local Sturmfeur = Tank:New{
	name              	= "Sturmfeur",
	description         = "Heavy LRM Tank",
	
	trackWidth			= 28,--width to render the decal
	
	weapons = {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
			maxAngleDif = 120,
		},
		[3] = {
			name	= "MG",
			SlaveTo = 1,
		},
		[4] = {
			name	= "MG",
			SlaveTo = 1,
		},
	},

	customparams = {
		tonnage			= 85,
		variant         = "",
		speed			= 50,
		price			= 14000,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 19.5},
		maxammo 		= {lrm = 3},
		squadsize 		= 1,
		--replaces		= "la_lrmcarrier",
    },
}

return lowerkeys({
	--["LA_Sturmfeur"] = Sturmfeur:New(),
})