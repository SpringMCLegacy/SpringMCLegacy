local Patton = Tank:New{
	name              	= "Patton",
	description         = "Heavy Brawler Tank",
	
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
		squadsize 		= 2,
    },
}

return lowerkeys({
	--["LA_Patton"] = Patton:New(),
})