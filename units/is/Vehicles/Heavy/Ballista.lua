local Ballista = Tank:New{
	name              	= "Ballista",
	description         = "Heavy Artillery Tank",
	trackWidth			= 28,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "Sniper",
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 60,
		price			= 5310,
		heatlimit 		= 10,
		armor			= 2,
		maxammo 		= {sniper = 2},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_Ballista"] = Ballista:New(),
	["DC_Ballista"] = Ballista:New(),
	["FS_Ballista"] = Ballista:New(),
	["FW_Ballista"] = Ballista:New(),
	["LA_Ballista"] = Ballista:New(),
})