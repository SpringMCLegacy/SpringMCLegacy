local LocustIIC = Light:New{
	name              	= "Locust IIC",
	customparams = {
		tonnage			= 25,
    },
}

local Mk2 = LocustIIC:New{
	description         = "Light Skirmisher",
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
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {srm = 1},
    },
}

local Mk3 = LocustIIC:New{
	description         = "Light Sniper",
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
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 4},
    },
}

local Mk5 = LocustIIC:New{
	description         = "Light Missile Support",
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
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {atm = 2},
    },
}

return lowerkeys({
	["JF_LocustIIC_Mk2"] = Mk2:New(),
	["SJ_LocustIIC_Mk3"] = Mk3:New(),
	["WF_LocustIIC_Mk5"] = Mk5:New(),
})