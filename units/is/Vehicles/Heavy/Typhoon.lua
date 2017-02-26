local Typhoon = Tank:New{
	name              	= "Typhoon",
	description         = "Heavy Brawler Tank",
	
	trackWidth			= 28,--width to render the decal
	
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "MPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MPL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "SRM6",
			SlaveTo = 1,
		},
		[5] = {
			name	= "SSRM4",
			SlaveTo = 1,
		},
		[6] = {
			name	= "SSRM4",
			maxAngleDif = 60,
		},
	},
	customparams = {
		tonnage			= 70,
		variant         = "",
		speed			= 50,
		price			= 6090,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 11.5},
		maxammo 		= {ac20 = 3, srm = 3},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		replaces		= "fs_demolisher",
		wheels			= true,
    },
}

return lowerkeys({
	["FS_Typhoon"] = Typhoon:New(),
})