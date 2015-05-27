local HunchbackII = Medium:New{
	name				= "Hunchback IIC",

	customparams = {
		tonnage			= 50,
    },	
}

local Prime = HunchbackII:New{
	description         = "Medium Brawler",
	weapons	= {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "UAC20",
		},
		[3] = {
			name	= "MBL",
		},
		[4] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		variant			= "Prime",
		speed			= 60,
		price			= 21000,
		heatlimit 		= 24,
		armor			= {type = "standard", tons = 6},
		maxammo 		= {ac20 = 2},
		jumpjets		= 4,
		barrelrecoildist = {[1] = 4, [2] = 4},
    },
}

return lowerkeys({
	["CL_HunchbackII_Prime"] = Prime:New(),
})