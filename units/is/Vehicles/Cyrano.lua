local Cyrano = VTOL:New{
	name              	= "Cyrano",
	description         = "Light VTOL",
	verticalSpeed	= 2,

	weapons	= {	
		[1] = {
			name	= "LBL",
			maxAngleDif = 30,
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "",
		speed			= 300,
		price			= 4590,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CC_Cyrano"] = Cyrano:New{},
	["DC_Cyrano"] = Cyrano:New{},
	["FS_Cyrano"] = Cyrano:New{},
	["FW_Cyrano"] = Cyrano:New{},
	["LA_Cyrano"] = Cyrano:New{},
})