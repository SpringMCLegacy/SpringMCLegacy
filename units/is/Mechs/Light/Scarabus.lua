local Scarabus = Light:New{
	name				= "Scarabus",
	
	customparams = {
		cockpitheight	= 15,
		tonnage			= 30,
    },
}

local SCB9A = Scarabus:New{
	description         = "Light EWAR Support",
	weapons	= {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "SBL",
		},
		[4] = {
			name	= "SBL",
		},
		[5] = {
			name	= "TAG",
		},
	},
		
	customparams = {
		variant         = "SCB-9A",
		speed			= 150,
		price			= 8460,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 5.5},
		ecm 			= true,
    },
}

return lowerkeys({
	["FS_Scarabus_SCB9A"] = SCB9A:New(),
	["LA_Scarabus_SCB9A"] = SCB9A:New(),
})