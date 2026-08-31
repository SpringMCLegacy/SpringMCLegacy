local Thanatos = Heavy:New{
	name				= "Thanatos",
	leaveTracks			= true,	
	trackType			= "Thanatos",
	trackOffset			= 6,
	trackWidth			= 46,
	trackStretch 		= 2,
    customparams = {
		cockpitheight	= 15.29,
		tonnage			= 75,
    },
}

local TNS4S = Thanatos:New{
	description         = "Heavy Skirmisher",
	weapons = {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "MPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MRM30",
		},
		[4] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "ERMBL",
			SlaveTo	= 4,
			OnlyTargetCategory = "ground",
		},
	},
		
    customparams = {
		variant			= "TNS-4S",
		speed			= 80,
		price			= 18440,
		heatlimit 		= 16,--16 double
		armor			= 13,
		maxammo 		= {mrm = 2},
		barrelrecoildist = {[1] = 4},
		ecm 			= true,
		jumpjets		= 5,
		mods			= {"jumpjets", "guardian", "doubleheatsinks", "endosteel", "xlengine"},
    },
}

return lowerkeys({ 
	["FS_Thanatos_TNS4S"] = TNS4S:New(),
	["LA_Thanatos_TNS4S"] = TNS4S:New(),
})