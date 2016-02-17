local Striker = LightTank:New{
	name              	= "Striker",
	description			= "LRM Support tank",
	
	trackWidth			= 18,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "ALRM15",
		},
		[2] = {
			name	= "SSRM4",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 80,
		price			= 6910,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 6.5},
		maxammo 		= {lrm = 1, srm = 1},
		squadsize 		= 1,
		replaces		= "fs_hunter",
    },
}

return lowerkeys({
	["FS_Striker"] = Striker:New(),
})