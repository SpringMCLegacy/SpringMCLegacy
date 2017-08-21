local Partisan = Tank:New{
	name              	= "Partisan",
	description         = "Heavy AA Tank",
	trackWidth			= 25,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "AC5_AA",
		},
		[2] = {
			name	= "AC5_AA",
		},
		[3] = {
			name	= "AC5_AA",
		},
		[4] = {
			name	= "AC5_AA",
		},
	},
	
	customparams = {
		tonnage			= 65,
		variant         = "",
		speed			= 50,
		price			= 6730,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 7},
		maxammo 		= {ac5 = 8},
		barrelrecoildist = {[1] = 1, [2] = 1, [3] = 1, [4] = 1},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_Partisan"] = Partisan:New(),
	["DC_Partisan"] = Partisan:New(),
	["FS_Partisan"] = Partisan:New(),
	["FW_Partisan"] = Partisan:New(),
	["LA_Partisan"] = Partisan:New(),
})