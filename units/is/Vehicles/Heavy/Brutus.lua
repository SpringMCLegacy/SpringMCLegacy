local Brutus = Tank:New{
	name              	= "Brutus",
	description         = "Heavy Striker Tank",
	trackWidth			= 27,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "LBL",
		},
		[2] = {
			name	= "LBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LRM20",
		},
		[4] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
		[5] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 75,
		variant         = "",
		speed			= 50,
		price			= 11150,
		heatlimit 		= 20,
		armor			= 8.5,
		maxammo 		= {srm = 2, lrm = 2},
		squadsize 		= 1,
		--replaces		= "cc_manticore",
    },
}

return lowerkeys({
	--["CC_Brutus"] = Brutus:New(),
})