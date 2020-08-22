local HeavyBRV = Tank:New{
	name              	= "Heavy BRV",
	description         = "Support Vehicle",
	trackType			= "Mars",--hueg like xbox
	trackWidth			= 48,--width to render the decal
	
	--weapons	= {	
	--},

	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 30,
		price			= 10170,
		heatlimit 		= 10,
		armor			= 10,
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
	},
}

return lowerkeys({
	["HeavyBRV"] = HeavyBRV:New(),
})