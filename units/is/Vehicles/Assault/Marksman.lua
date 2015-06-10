local Marksman = LightTank:New{
	name              	= "Marksman",
	description         = "Artillery",
	
	weapons	= {	
		[1] = {
			name	= "Sniper",
			maxAngleDif = 15,
		},
		[2] = {
			name	= "ERSBL",
		},
		[3] = {
			name	= "ERSBL",
		},
	},
	
	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 3920,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 7.5},
		maxammo 		= {sniper = 4},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["FS_Marksman"] = Marksman:New(),
	["LA_Marksman"] = Marksman:New(),
})