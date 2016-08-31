local Patton = Tank:New{
	name              	= "Patton",
	description         = "Heavy Striker Tank",
	trackWidth			= 25,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "ERSBL",
		},
		[3] = {
			name	= "LRM5",
		},
		[4] = {
			name	= "Flamer",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 65,
		variant         = "",
		speed			= 60,
		price			= 9610,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 12.5},
		maxammo 		= {ac10 = 3, lrm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		replaces		= "la_manticore",
    },
}

return lowerkeys({
	["LA_Patton"] = Patton:New(),
})