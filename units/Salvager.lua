local Salvager = LightTank:New{
	name              	= "Salvager",
	description         = "Support Vehicle",
	trackWidth			= 25,--width to render the decal
	
	builder 			= true,
	canReclaim 			= true,
	canRepair			= false,
	harvestStorage		= 1000,
	workerTime			= 200,
	buildDistance 		= 50,
	
	--weapons	= {	
	--},

	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 50,
		price			= 10170,
		heatlimit 		= 10,
		armor			= 6,
		squadsize 		= 1,
	},
}

return lowerkeys({
	["Salvager"] = Salvager:New(),
})