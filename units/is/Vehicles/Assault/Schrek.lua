local SchrekBase = Tank:New{
	name              	= "Schrek",
	description         = "Heavy Sniper Tank",
	trackWidth			= 23,--width to render the decal

	
	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 9350,
		heatlimit 		= 30,
		armor			= {type = "standard", tons = 7},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		squadsize 		= 1,
	},
}
	
local Schrek = SchrekBase:New{
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "PPC",
		},
	},
}

local SchrekArmor = SchrekBase:New{
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "PPC",
		},
		[4] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		tonnage			= 80,
		variant         = "(Armor)",
		speed			= 50,
		price			= 10400,
		heatlimit 		= 32,
		armor			= {type = "hferro", tons = 7},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		squadsize 		= 1,
		replaces		= "cc_schrek",
	},
}

local SchrekC3M = SchrekBase:New{
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "LightPPC",
		},
		[3] = {
			name	= "PPC",
		},
		[4] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		tonnage			= 80,
		variant         = "(C3M)",
		speed			= 50,
		price			= 9930,
		heatlimit 		= 32,
		ecm				= true,
		armor			= {type = "hferro", tons = 7},
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		squadsize 		= 1,
		replaces		= "dc_schrek",
	},
}

return lowerkeys({
	["CC_Schrek"] = Schrek:New(),
	["CC_SchrekArmor"] = SchrekArmor:New(),
	["DC_Schrek"] = Schrek:New(),
	["DC_SchrekC3M"] = SchrekC3M:New(),
	["FS_Schrek"] = Schrek:New(),
	["FW_Schrek"] = Schrek:New(),
	["LA_Schrek"] = Schrek:New(),
})