local Devastator = Assault:New{
	name				= "Devastator",
	
	leaveTracks			= true,	
	trackType			= "Devastator",
	trackOffset			= 6,
	trackWidth			= 46,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 20.34,
		tonnage			= 100,
    },
}

local DVS2 = Devastator:New{
	description         = "Assault Vanguard",
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
		heatlimit 		= 14,--14 double
		armor			= 18.5,
		maxammo 		= {gauss = 4},
		barrelrecoildist = {[1] = 5, [2] = 5},
		mods			= {"doubleheatsinks", "xlengine"},
    },
}

return lowerkeys({
	["FS_Devastator_DVS2"] = DVS2:New(),
})