local Rommel = Tank:New{
	name              	= "Rommel",
	description         = "Heavy Brawler Tank",
	
	weapons	= {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "ERSBL",
		},
		[3] = {
			name	= "LRM5",
		},
	},
	
	customparams = {
		tonnage			= 65,
		variant         = "",
		speed			= 60,
		price			= 9610,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 11.5},
		maxammo 		= {ac20 = 2, lrm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
    },
}

return lowerkeys({
	--["LA_Rommel"] = Rommel:New(),
})