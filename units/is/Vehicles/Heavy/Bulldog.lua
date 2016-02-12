local BulldogBase = Tank:New{
	name              	= "Bulldog",
	description         = "Heavy Striker Tank",
	
	trackWidth			= 27,--width to render the decal
	
	customparams = {
		tonnage			= 50,
		variant         = "",
		speed			= 60,
		price			= 7050,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 6.5},
		maxammo 		= {srm = 1},
		squadsize 		= 2,
    },
}

local Bulldog = BulldogBase:New{
	weapons	= {	
		[1] = {
			name	= "LBL",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "SRM4",
		},
		[4] = {
			name	= "MG",
			maxAngleDif = 60,
		},
	},
}
	
return lowerkeys({
	["CC_Bulldog"] = Bulldog:New(),
	["DC_Bulldog"] = Bulldog:New(),
	["FS_Bulldog"] = Bulldog:New(),
	["FW_Bulldog"] = Bulldog:New(),
	["LA_Bulldog"] = Bulldog:New(),
})