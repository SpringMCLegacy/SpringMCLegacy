local Myrmidon = LightTank:New{
	name              	= "Myrmidon",
	description			= "Medium Sniper",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "SRM6",
		},
	},
	
	customparams = {
		tonnage			= 40,
		variant         = "",
		speed			= 80,
		price			= 6020,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 9},
		maxammo 		= {srm = 1},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_Myrmidon"] = Myrmidon:New(),
	["DC_Myrmidon"] = Myrmidon:New(),
	["FS_Myrmidon"] = Myrmidon:New(),
	["FW_Myrmidon"] = Myrmidon:New(),
	["LA_Myrmidon"] = Myrmidon:New(),
})