local Brunel = Tank:New{
	name              	= "Brunel",
	description         = "Heavy Dump Truck",
	
	trackWidth			= 28,--width to render the decal

	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 3000,
		heatlimit 		= 10,
		armor			= 4,
		squadsize 		= 1,
		trackwidth		= 56,
    },
}

return lowerkeys({
	["Brunel"] = Brunel:New(),
})