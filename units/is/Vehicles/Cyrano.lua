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
	["CC_Cyrano"] = Cyrano,
	["DC_Cyrano"] = Cyrano,
	["FS_Cyrano"] = Cyrano,
	["FW_Cyrano"] = Cyrano,
	["LA_Cyrano"] = Cyrano,
})