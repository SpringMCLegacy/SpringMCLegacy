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
		artillery 		= true,
    },
}

return lowerkeys({
	--["CC_Marksman"] = Marksman:New(),
	--["DC_Marksman"] = Marksman:New(),
	--["FS_Marksman"] = Marksman:New(),
	--["FW_Marksman"] = Marksman:New(),
	--["LA_Marksman"] = Marksman:New(),
})