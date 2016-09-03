local Plainsman = Hover:New{
	name              	= "Plainsman",
	description			= "Light Harasser",
	
	weapons 		= {	
		[1] = {
			name	= "SSRM4",
		},
		[2] = {
			name	= "SSRM4",
			SlaveTo = 1,
		},
		[3] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 140,
		price			= 4130,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3.5},
		maxammo 		= {srm = 2},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["LA_Plainsman"] = Plainsman:New{customParams = { replaces = "la_pegasus" }},
	["CC_Plainsman"] = Plainsman:New{customParams = { replaces = "cc_pegasus" }},
})