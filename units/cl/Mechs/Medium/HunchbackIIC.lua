local HunchbackIIC = Medium:New{
	name				= "Hunchback IIC",

	customparams = {
		tonnage			= 50,
    },	
}

local Mk1 = HunchbackIIC:New{
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
		variant			= "Mk 1",
		speed			= 60,
		price			= 16790,
		heatlimit 		= 24,
		armor			= {type = "standard", tons = 6},
		maxammo 		= {ac20 = 2},
		jumpjets		= 4,
		barrelrecoildist = {[1] = 4, [2] = 4},
    },
}

return lowerkeys({
	["WF_HunchbackIIC_Mk1"] = Mk1:New(),
	["HH_HunchbackIIC_Mk1"] = Mk1:New(),
	["GB_HunchbackIIC_Mk1"] = Mk1:New(),
	["JF_HunchbackIIC_Mk1"] = Mk1:New(),
	["SJ_HunchbackIIC_Mk1"] = Mk1:New(),
})