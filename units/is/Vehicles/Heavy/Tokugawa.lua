local Tokugawa = Tank:New{
	name              	= "Tokugawa",
	description         = "Heavy Strike Tank",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "ASRM6",
		},
		[3] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 60,
		price			= 7190,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 10.5},
		maxammo 		= {ac10 = 3, srm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		--replaces		= "dc_manticore",
		wheels			= true,
    },
}

return lowerkeys({
	["DC_Tokugawa"] = Tokugawa:New(),
})