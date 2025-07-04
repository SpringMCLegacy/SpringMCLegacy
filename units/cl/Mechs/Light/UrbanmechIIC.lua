local UrbanmechIIC = Light:New{
	name              	= "Urbanmech IIC",
	
	leaveTracks			= true,	
	trackType			= "Urbanmech",
	trackOffset			= 6,
	trackWidth			= 24,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 8,
		tonnage			= 30,
		torsoturnspeed	= 210,
    },
}

local Mk1 = UrbanmechIIC:New{
	description         = "Light Ambush Brawler",
	weapons = {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "CERSBL",
		},
	},
		
	customparams = {
		variant         = "Mk1",
		speed			= 50,
		price			= 7980,
		heatlimit 		= 10,
		armor			= 6,
		jumpjets		= 6,
		maxammo 		= {ac10 = 1},
		barrelrecoildist = {[1] = 4},
    },
}



return lowerkeys({
	["WF_UrbanmechIIC_Mk1"] = Mk1:New(),
})