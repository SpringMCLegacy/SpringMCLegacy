local Icestorm = Light:New{
	name				= "Icestorm",
	
	customparams = {
		tonnage			= 25,
    },
}

local Mk1 = Icestorm:New{
	description         = "Light Scout",
	
	weapons = {	
		[1] = {
			name	= "CERMBL",
		},
		[2] = {
			name	= "SRM2",
		},
		[3] = {
			name	= "TAG",
		},
	},

	customparams = {
		variant         = "Mk 1",
		speed			= 180,
		price			= 7280,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
		maxammo 		= {srm = 1},
    },
}

return lowerkeys({
	["WF_Icestorm_Mk1"] = Mk1:New(),
})