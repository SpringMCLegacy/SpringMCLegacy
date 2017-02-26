local Goblin = LightTank:New{
	name              	= "Goblin",
	trackWidth			= 23,--width to render the decal
	transportCapacity		= 5,
	transportSize = 1,	
	
	customparams = {
		tonnage			= 45,
    },
}

local GoblinTransport = Goblin:New{
	description         = "Infantry Transport",
	
	weapons	= {	
		[1] = {
			name	= "LBL",
		},
		[2] = {
			name	= "MG",
			maxAngleDif = 180,
		},
	},
	
	customparams = {
		variant         = "",
		speed			= 60,
		price			= 5550,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 8},
		squadsize 		= 1,
    },
}

local GoblinIFV = Goblin:New{
	description         = "Infantry Fighting Vehicle",
	
	weapons	= {	
		[1] = {
			name	= "LPL",
		},
		[2] = {
			name	= "SRM6",
		},
		[3] = {
			name	= "MG",
			mainDir = [[-1 0 1]],
			maxAngleDif = 90,
		},
		[4] = {
			name	= "MG",
			mainDir = [[1 0 1]],
			maxAngleDif = 90,
		},
		[5] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		variant         = "IFV",
		speed			= 60,
		price			= 7900,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 8},
		maxammo 		= {srm = 2},
		squadsize 		= 1,
		replaces		= "fs_goblintransport",
    },
}

	
return lowerkeys({
	["DC_GoblinTransport"] = GoblinTransport:New(),
	["FS_GoblinTransport"] = GoblinTransport:New(),
	["FS_GoblinIFV"] = GoblinIFV:New(),
	["LA_GoblinTransport"] = GoblinTransport:New(),
	["CC_GoblinTransport"] = GoblinTransport:New(),
	["FW_GoblinTransport"] = GoblinTransport:New(),
})