local Donar = VTOL:New{
	name              	= "Donar",
	description         = "Attack VTOL",
	verticalSpeed	= 2,

	weapons	= {	
		[1] = {
			name	= "CERLBL",
			maxAngleDif = 180,
		},
		[2] = {
			name	= "SSRM2",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "SSRM2",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 21,
		variant         = "",
		speed			= 240,
		price			= 9150,
		heatlimit 		= 20,
		armor			= 3,
		maxammo 		= {srm = 1},
		squadsize 		= 2,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Donar"] = Donar:New{},
})