local Panther = Light:New{
	name              	= "Panther",
	
	leaveTracks			= true,	
	trackType			= "Panther",
	trackOffset			= 6,
	trackWidth			= 20,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 8,
		tonnage 		= 35,
    },
}

local PNT10K = Panther:New{
	description         = "Light Vanguard",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "SRM4",
		},
	},
		
	customparams = {
		variant         = "PNT-10K",
		speed			= 60,
		price			= 8380,
		heatlimit 		= 13, --13 single
		jumpjets		= 4,
		armor			= 6.5,
		maxammo 		= {srm = 2},
		mods 			= {"jumpjets", "artemissrm", "ferrofibrousarmour", "endosteel", "case"},
    },
}

return lowerkeys({
	["DC_Panther_PNT10K"] = PNT10K:New(),
})