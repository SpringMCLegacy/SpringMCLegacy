local Ishtar = Tank:New{
	name              	= "Ishtar",
	description         = "Heavy Brawler Tank",
	trackWidth			= 28,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "LBX10",
		},
		[3] = {
			name	= "CERMBL",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "CERMBL",
			maxAngleDif = 60,
		},
		[5] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		tonnage			= 65,
		variant         = "",
		speed			= 50,
		price			= 14040,
		heatlimit 		= 20,
		armor			= 7.5,
		maxammo 		= {ac10 = 4, lrm = 2},
		barrelrecoildist = {[1] = 1, [2] = 3},
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Ishtar"] = Ishtar:New(),
})