local HeavyBRV = Tank:New{
	name              	= "Heavy BRV",
	description         = "Support Vehicle",
	trackWidth			= 38,--width to render the decal
	
	--weapons	= {	
	--},

	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 30,
		price			= 10170,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 10},
		squadsize 		= 1,
	},
}

return lowerkeys({
	["HeavyBRV"] = HeavyBRV:New(),
})