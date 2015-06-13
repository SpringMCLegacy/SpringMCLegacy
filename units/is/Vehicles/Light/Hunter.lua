local Hunter = LightTank:New{
	name              	= "Hunter",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "Upgrade",
		speed			= 60,
		price			= 6410,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {lrm = 2},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["LA_Hunter"] = Hunter,
})