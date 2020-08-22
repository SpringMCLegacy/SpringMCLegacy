local LocustIIC = Light:New{
	name              	= "Locust IIC",
	customparams = {
		tonnage			= 25,
		cockpitheight	= 1.6,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
    },
}

local Mk2 = LocustIIC:New{
	description         = "Light Striker",
	weapons = {	
		[1] = {
			name	= "SSRM4",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "CERMBL",
		},
	},
		
	customparams = {
		variant         = "Mk 2",
		speed			= 120,
		price			= 9370,
		heatlimit 		= 13,
		armor			= 4,
		maxammo 		= {srm = 1},
    },
}

local Mk3 = LocustIIC:New{
	description         = "Light Ranged",
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CSPL",
		},
		[3] = {
			name	= "CSPL",
		},
	},
		
	customparams = {
		variant         = "Mk 3",
		speed			= 120,
		price			= 9800,
		heatlimit 		= 13,
		armor			= 4,
    },
}

local Mk5 = LocustIIC:New{
	description         = "Light Ranged",
	weapons = {	
		[1] = {
			name	= "ATM3",
		},
		[2] = {
			name	= "ATM3",
		},
		[3] = {
			name	= "CERMBL",
		},
	},
		
	customparams = {
		variant         = "Mk 5",
		speed			= 120,
		price			= 8780,
		heatlimit 		= 13,
		armor			= 4,
		maxammo 		= {atm = 2},
    },
}

return lowerkeys({
	["WF_LocustIIC_Mk5"] = Mk5:New(),
})