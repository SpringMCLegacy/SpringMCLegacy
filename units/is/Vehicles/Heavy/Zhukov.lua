local Zhukov = Tank:New{
	name              	= "Zhukov",
	description         = "Heavy Brawler Tank",
	trackWidth			= 25,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "LBX10",
		},
		[3] = {
			name	= "SRM4",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 75,
		variant         = "",
		speed			= 50,
		price			= 10210,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 11},
		maxammo 		= {ac10 = 3, srm = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		replaces		= "cc_manticore",
    },
}

return lowerkeys({
	["CC_Zhukov"] = Zhukov:New(),
})