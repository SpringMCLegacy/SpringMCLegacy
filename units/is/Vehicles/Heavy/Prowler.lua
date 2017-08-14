local Prowler = LightTank:New{
	name              	= "Prowler",
	description         = "IFV",
	transportCapacity		= 5,
	transportSize = 1,	
	trackWidth			= 26,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LRM10",
			SlaveTo = 1,
		},
		[4] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		variant         = "",
		speed			= 60,
		tonnage			= 55,
		price			= 7210,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 7},
		maxammo 		= {lrm = 2, srm = 1},
		squadsize 		= 1,
		--replaces		= "la_goblintransport",
    },
}

return lowerkeys({
	["LA_Prowler"] = Prowler:New(),
})