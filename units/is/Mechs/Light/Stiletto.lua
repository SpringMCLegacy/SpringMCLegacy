local Stiletto = Light:New{
	name				= "Stiletto",
	
	customparams = {
		cockpitheight	= 2.6,
		tonnage			= 35,
    },
}

local STO4A = Stiletto:New{
	description         = "Light Missile Support",
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
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 6},
		ecm 			= true,
		maxammo 		= {lrm = 1, srm = 1},
    },
}

return lowerkeys({
	["LA_Stiletto_STO4A"] = STO4A:New(),
})