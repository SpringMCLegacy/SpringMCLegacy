local HunterBase = LightTank:New{
	name              	= "Hunter",
	description         = "LRM Support Tank",
	
	trackWidth			= 23,--width to render the decal
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 60,
		price			= 6000,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 6},
		maxammo 		= {lrm = 2},
		squadsize 		= 1,
    },
}

local Hunter = HunterBase:New{
	weapons	= {	
		[1] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
	},
}

local HunterS = HunterBase:New{
	description         = "Heavy Brawler Tank",
	
	weapons	= {	
		[1] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "LRM15",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		variant         = "(Steiner)",
		speed			= 60,
		price			= 7000,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {lrm = 2},
		squadsize 		= 1,
		replaces		= "la_hunter",
    },
}
	
return lowerkeys({
	["CC_Hunter"] = Hunter:New(),
	["DC_Hunter"] = Hunter:New(),
	["FS_Hunter"] = Hunter:New(),
	["FW_Hunter"] = Hunter:New(),
	["LA_Hunter"] = Hunter:New(),
	["LA_HunterS"] = HunterS:New(),
})