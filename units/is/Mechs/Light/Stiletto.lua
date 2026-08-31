local Stiletto = Light:New{
	name				= "Stiletto",
	
	leaveTracks			= true,	
	trackType			= "Stiletto",
	trackOffset			= 6,
	trackWidth			= 24,
	trackStretch 		= 2.5,
	
	customparams = {
		cockpitheight	= 6.55,
		tonnage			= 35,
    },
}

local STO4A = Stiletto:New{
	description         = "Light Scout",
	weapons	= {	
		[1] = {
			name	= "SSRM2",
		},
		[2] = {
			name	= "SSRM2",
		},
		[3] = {
			name	= "LRM5",
		},
	},
		
	customparams = {
		variant         = "STO-4A",
		speed			= 120,
		price			= 8590,
		heatlimit 		= 10,--10 Double
		armor			= 6,
		ecm 			= true,
		maxammo 		= {lrm = 1, srm = 1},
		mods 			= {"guardian", "ferrofibrousarmour", "doubleheatsinks", "endosteel", "lightengine", "case"},
    },
}

return lowerkeys({
	["LA_Stiletto_STO4A"] = STO4A:New(),
})