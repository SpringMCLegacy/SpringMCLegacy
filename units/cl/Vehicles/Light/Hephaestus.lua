local Hephaestus = Hover:New{
	name              	= "Hephaestus",
	description			= "Light Skirmisher",
	
	weapons 		= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
			SlaveTo = 1,
		},
		[3] = {
			name	= "TAG",
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "Prime",
		speed			= 130,
		price			= 7770,
		heatlimit 		= 10,
		armor			= 5,
		ecm				= true,
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Hephaestus"] = Hephaestus:New(),
})