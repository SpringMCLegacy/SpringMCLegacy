local J27 = Tank:New{
	name              	= "J-27 Ordnance Transport",
	description         = "Resupply Vehicle - Loads an entire wreck and deposits it at the salvage yard for recovery or scrapping.",
	trackWidth			= 27,--width to render the decal
	
	holdSteady = true,
	--weapons	= {	
	--},
	
	customparams = {
		tonnage			= 30,
		variant         = "",
		speed			= 60,
		price			= 8900,
		heatlimit 		= 10,
		armor			= 1,
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
		hitchmaxy		= 60,
		uniformbin		= "treads2k",
		cratetype		= "cratelong",
	},
}

return lowerkeys({
	["J27"] = J27:New(),
})