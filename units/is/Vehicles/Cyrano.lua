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
		speed			= 190,
		price			= 4590,
		heatlimit 		= 10,
		armor			= 1,
		squadsize 		= 2,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["CC_Cyrano"] = Cyrano:New{},
	["DC_Cyrano"] = Cyrano:New{},
	["FS_Cyrano"] = Cyrano:New{},
	["FW_Cyrano"] = Cyrano:New{},
	["LA_Cyrano"] = Cyrano:New{},
})