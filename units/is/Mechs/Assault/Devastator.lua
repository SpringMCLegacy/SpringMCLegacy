local Devastator = Assault:New{
	name				= "Devastator",
	
	customparams = {
		cockpitheight	= 9.4,
		tonnage			= 100,
    },
}

local DVS2 = Devastator:New{
	description         = "Assault Multirole",
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "Gauss",
		},
		[3] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		variant			= "DVS-2",
		speed			= 50,
		price			= 24810,
		heatlimit 		= 28,
		armor			= {type = "standard", tons = 18.5},
		maxammo 		= {gauss = 4},
		barrelrecoildist = {[1] = 5, [2] = 5},
    },
}

return lowerkeys({
	["FS_Devastator_DVS2"] = DVS2:New(),
})