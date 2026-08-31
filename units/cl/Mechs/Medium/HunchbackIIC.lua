local HunchbackIIC = Medium:New{
	name				= "Hunchback IIC",

	leaveTracks			= true,	
	trackType			= "Hunchback",
	trackOffset			= 6,
	trackWidth			= 26,
	trackStretch 		= 2,
	
	customparams = {
		tonnage			= 50,
		cockpitheight	= 17.14,
		mods			= {"jumpjets", "doubleheatsinks", "endosteel", "xlengine"},
    },	
}

local Mk1 = HunchbackIIC:New{
	description         = "Medium Ambush Brawler",
	weapons	= {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "UAC20",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
			SlaveTo = 3,
		},
	},
		
	customparams = {
		variant			= "Mk 1",
		speed			= 60,
		price			= 16790,
		heatlimit 		= 12,--12 double
		armor			= 6,
		maxammo 		= {ac20 = 2},
		jumpjets		= 4,
		barrelrecoildist = {[1] = 4, [2] = 4},
    },
}

local Mk2 = HunchbackIIC:New{
	description         = "Medium Striker",
	weapons	= {	
		[1] = {
			name	= "HLBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "HLBL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "HLBL",
			SlaveTo = 1,
		},
		[4] = {
			name	= "HLBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "HLBL",
			SlaveTo = 4,
		},
		[6] = {
			name	= "HLBL",
			SlaveTo = 4,
		},
		[7] = {
			name	= "CMPL",
		},
		[8] = {
			name	= "CMPL",
			SlaveTo = 7,
		},
	},
		
	customparams = {
		variant			= "Mk 2",
		speed			= 60,
		price			= 18690,
		heatlimit 		= 19, --19 double
		armor			= 6,
		jumpjets		= 4,
    },
}

return lowerkeys({
	["WF_HunchbackIIC_Mk1"] = Mk1:New(),
	["WF_HunchbackIIC_Mk2"] = Mk2:New(),
	--["HH_HunchbackIIC_Mk1"] = Mk1:New(),
	--["GB_HunchbackIIC_Mk1"] = Mk1:New(),
	--["JF_HunchbackIIC_Mk1"] = Mk1:New(),
	["SJ_HunchbackIIC_Mk1"] = Mk1:New(),
})