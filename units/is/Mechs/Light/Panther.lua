local Panther = Light:New{
	name              	= "Panther",
	
	customparams = {
		cockpitheight	= 8,
		tonnage 		= 35,
    },
}

local PNT10K = Panther:New{
	description         = "Light Brawler",
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
		heatlimit 		= 13,
		jumpjets		= 4,
		armor			= 6.5,
		maxammo 		= {srm = 2},
		mods 			= {"artemissrm","ferrofibrousarmour"},
    },
}

return lowerkeys({
	["DC_Panther_PNT10K"] = PNT10K:New(),
})