local Striker = LightTank:New{
	name              	= "Striker",
	
	weapons 		= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "SSRM4",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "",
		speed			= 80,
		price			= 4490,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 3},
		maxammo 		= {lrm = 2, srm = 1},
		squadsize 		= 1,
		artillery 		= true,
    },
}

return lowerkeys({
	["FS_Striker"] = Striker:New(),
})