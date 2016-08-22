local BRV = Tank:New{
	name              	= "BRV",
	description         = "Support Vehicle",
	trackWidth			=25,--width to render the decal
	
	--weapons	= {	
	--},

	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 10170,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 6},
		squadsize 		= 1,
	},
}

return lowerkeys({
	["BRV"] = BRV:New(),
})