local Wolftrap = Medium:New{
	name				= "Wolf Trap",
	
	leaveTracks			= true,	
	trackType			= "Wolftrap",
	trackOffset			= 6,
	trackWidth			= 36,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 9.5,
		tonnage			= 45,
    },
}

local WFT1 = Wolftrap:New{
	description         = "Medium Vanguard",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "LRM10",
		},
	},

	customparams = {
		variant			= "WFT-1",
		speed			= 90,
		price			= 10700,
		heatlimit 		= 10,--10 single
		armor			= 7.5,
		maxammo 		= {ac10 = 2, lrm = 1},
		mods			= {"xlengine", "endosteel", "case"},
		barrelrecoildist = {[1] = 3,},
    },
}

return lowerkeys({ 
	["DC_Wolftrap_WFT1"] = WFT1:New(),
})