local Urbanmech = Light:New{
	name              	= "Urbanmech",
	customparams = {
		tonnage			= 25,
    },
}

local UMR60L = Urbanmech:New{
	description         = "Light Skirmisher",
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "SBL",
		},
	},
		
	customparams = {
		variant         = "UM-R60L",
		speed			= 30,
		price			= 4700,
		heatlimit 		= 11,
		armor			= {type = "standard", tons = 4},
		maxammo 		= {ac20 = 1},
		barrelrecoildist = {[1] = 4},
    },
}

return lowerkeys({
	["CC_Urbanmech_UMR60L"] = UMR60L:New(),
})