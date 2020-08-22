local Hachiman = LightTank:New{
	name              	= "Hachiman",
	trackWidth			= 16,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
			SlaveTo = 3,
		},
		[5] = {
			name	= "SSRM4",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 55,
		variant         = "",
		speed			= 60,
		price			= 14840,
		heatlimit 		= 20,
		armor			= 7,
		maxammo 		= {lrm = 4, srm = 2},
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Hachiman"] = Hachiman:New(),
})