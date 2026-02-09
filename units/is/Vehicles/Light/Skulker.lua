local Skulker = LightTank:New{
	name              	= "Skulker",
	description			= "Light Scout",
	
	trackWidth			= 14,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "MBL",
		},
	},
	
	customparams = {
		tonnage			= 20,
		variant         = "",
		speed			= 110,
		price			= 1150,
		heatlimit 		= 10,
		armor			= 4.5,
		maxammo 		= {srm = 1},
		squadsize 		= 3,
		wheels			= true,
    },
}

return lowerkeys({
	["CC_Skulker"] = Skulker:New(),
	["DC_Skulker"] = Skulker:New(),
	["FS_Skulker"] = Skulker:New(),
	["FW_Skulker"] = Skulker:New(),
	["LA_Skulker"] = Skulker:New(),
})