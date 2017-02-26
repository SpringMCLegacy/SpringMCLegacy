local Packrat = LightTank:New{
	name              	= "Packrat",
	trackWidth			= 16,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 20,
		variant         = "",
		speed			= 120,
		price			= 2100,
		heatlimit 		= 10,
		armor			= {type = "std", tons = 3},
		maxammo 		= {srm = 1},
		squadsize 		= 3,
		wheels			= true,
    },
}

return lowerkeys({
	["CC_Packrat"] = Packrat:New(),
	["DC_Packrat"] = Packrat:New(),
	["FS_Packrat"] = Packrat:New(),
	["FW_Packrat"] = Packrat:New(),
	["LA_Packrat"] = Packrat:New(),
})