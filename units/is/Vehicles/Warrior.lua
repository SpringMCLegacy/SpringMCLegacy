local Warrior = VTOL:New{
	name              	= "Warrior",
	description         = "Light Attack VTOL",
	verticalSpeed	= 2,

	weapons	= {	
		[1] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "SRM2",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "AC2",
			maxAngleDif = 180,
		},
	},
	
	customparams = {
		tonnage			= 25,
		variant         = "",
		speed			= 230,
		price			= 3340,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 3},
		maxammo 		= {ac2 = 2, srm = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CC_Warrior"] = Warrior,
	["DC_Warrior"] = Warrior,
	["FS_Warrior"] = Warrior,
	["FW_Warrior"] = Warrior,
	["LA_Warrior"] = Warrior,
})