local Savannah = Hover:New{
	name              	= "Savannah Master",
	description			= "Ultralight Scout",
	
	weapons 		= {	
		[1] = {
			name	= "MBL",
			maxAngleDif = 10,
		},
	},
	
	customparams = {
		tonnage			= 5,
		variant         = "",
		speed			= 200,
		price			= 6060,
		heatlimit 		= 10,
		armor			= 0.55,
		squadsize 		= 4,
    },
}

return lowerkeys({
	["CC_Savannah"] = Savannah:New(),
	["DC_Savannah"] = Savannah:New(),
	["FS_Savannah"] = Savannah:New(),
	["FW_Savannah"] = Savannah:New(),
	["LA_Savannah"] = Savannah:New(),
})