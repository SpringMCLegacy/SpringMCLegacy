local Scarabus = Light:New{
	name				= "Scarabus",
	
	customparams = {
		cockpitheight	= 8.3,
		tonnage			= 30,
    },
}

local SCB9A = Scarabus:New{
	description         = "Light Scout",
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
		armor			= 5.5,
		ecm 			= true,
		mods 			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["FS_Scarabus_SCB9A"] = SCB9A:New(),
	["LA_Scarabus_SCB9A"] = SCB9A:New(),
})