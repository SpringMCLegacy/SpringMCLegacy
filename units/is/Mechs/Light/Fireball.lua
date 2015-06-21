local Fireball = Light:New{
	name              	= "Fireball",
	customparams = {
		tonnage			= 20,
    },
}

local ALM9D = Fireball:New{
	description         = "Light Skirmisher",
	weapons = {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "SSRM2",
		},
	},
		
	customparams = {
		variant         = "ALM-9D",
		speed			= 170,
		price			= 6740,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4.5},
		maxammo 		= {srm = 1},
    },
}

return lowerkeys({
	["FS_Fireball_ALM9D"] = ALM9D:New(),
})