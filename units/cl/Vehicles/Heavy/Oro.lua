local Oro = Tank:New{
	name              	= "Oro",
	description         = "Heavy Brawler Tank",
	trackWidth			= 27,--width to render the decal
	
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
		armor			= 5.5,
		maxammo 		= {ac20 = 3},
		barrelrecoildist = {[1] = 3},
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Oro"] = Oro:New(),
})