local Oro = Tank:New{
	name              	= "Oro",
	description         = "Heavy Brawler Tank",
	
	weapons	= {	
		[1] = {
			name	= "LBX20",
		},
		[2] = {
			name	= "CLPL",
		},
		[3] = {
			name	= "CERMBL",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 60,
		price			= 9610,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 5.5},
		maxammo 		= {ac20 = 3},
		barrelrecoildist = {[1] = 3},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["WF_Oro"] = Oro:New(),
})