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
		speed			= 160,
		price			= 3340,
		heatlimit 		= 10,
		armor			= 3,
		maxammo 		= {ac2 = 2, srm = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CC_Warrior"] = Warrior:New{},
	["DC_Warrior"] = Warrior:New{},
	["FS_Warrior"] = Warrior:New{},
	["FW_Warrior"] = Warrior:New{},
	["LA_Warrior"] = Warrior:New{},
})