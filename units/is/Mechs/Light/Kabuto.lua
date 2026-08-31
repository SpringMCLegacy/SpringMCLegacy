local Kabuto = Light:New{
	name              	= "Kabuto",
	
	leaveTracks			= true,	
	trackType			= "Kabuto",
	trackOffset			= 6,
	trackWidth			= 24,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 10.95,
		tonnage 		= 20,
    },
}

local KBO7A = Kabuto:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "SSRM4",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "SSRM4",
			SlaveTo = 1,
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant         = "KBO-7A",
		speed			= 110,
		price			= 5240,
		heatlimit 		= 10,
		armor			= 4.5,
		maxammo 		= {srm = 2},
		mods 			= {"xlengine", "endosteel"},
    },
}

return lowerkeys({
	["DC_Kabuto_KBO7A"] = KBO7A:New(),
})