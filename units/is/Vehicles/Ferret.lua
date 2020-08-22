local Ferret = VTOL:New{
	name              	= "Ferret",
	description         = "Scout VTOL",
	verticalSpeed	= 2,

	weapons	= {	
		[1] = {
			name	= "MG",
			maxAngleDif = 90,
		},
	},
	
	customparams = {
		tonnage			= 10,
		variant         = "",
		speed			= 400,
		price			= 580,
		heatlimit 		= 10,
		armor			= 1,
		squadsize 		= 2,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["CC_Ferret"] = Ferret:New{},
	["DC_Ferret"] = Ferret:New{},
	["FS_Ferret"] = Ferret:New{},
	["FW_Ferret"] = Ferret:New{},
	["LA_Ferret"] = Ferret:New{},
})