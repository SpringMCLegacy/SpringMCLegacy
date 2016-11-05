local Demolisher = Tank:New{
	name              	= "Demolisher",
	description         = "Heavy Brawler Tank",
	
	trackWidth			= 28,--width to render the decal
	
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "AC20",
		},
	},

	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 6090,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 12},
		maxammo 		= {ac20 = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		trackwidth		= 56,
    },
}

return lowerkeys({
	["CC_Demolisher"] = Demolisher:New(),
	["DC_Demolisher"] = Demolisher:New(),
	["FS_Demolisher"] = Demolisher:New(),
	["FW_Demolisher"] = Demolisher:New(),
	["LA_Demolisher"] = Demolisher:New(),
})