local Kabuto = Light:New{
	name              	= "Kabuto",
	customparams = {
		cockpitheight	= 5.95,
		tonnage 		= 20,
    },
}

local KBO7A = Kabuto:New{
	description         = "Light Skirmisher",
	weapons	= {	
		[1] = {
			name	= "SSRM4",
		},
		[2] = {
			name	= "SSRM4",
		},
	},
		
	customparams = {
		variant         = "KBO-7A",
		speed			= 110,
		price			= 5240,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4.5},
		maxammo 		= {srm = 2},
    },
}

return lowerkeys({
	["DC_Kabuto_KBO7A"] = KBO7A:New(),
})