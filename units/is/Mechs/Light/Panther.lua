local Panther = Light:New{
	name              	= "Panther",
	customparams = {
		tonnage 		= 35,
    },
}

local PNT10K = Panther:New{
	description         = "Light Sniper",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ASRM4",
		},
	},
		
	customparams = {
		variant         = "PNT-10K",
		speed			= 60,
		price			= 8380,
		heatlimit 		= 13,
		jumpjets		= 4,
		armor			= {type = "standard", tons = 6.5},
		maxammo 		= {srm = 2},
    },
}

return lowerkeys({
	["DC_Panther_PNT10K"] = PNT10K:New(),
})