local Salvager = LightTank:New{
	name              	= "Salvager",
	description         = "Support Vehicle - Gradually removes salvage from wrecks and deposits it at the salvage yard.",
	trackWidth			= 25,--width to render the decal
	
	builder 			= true,
	canReclaim 			= true,
	--canResurrect 		= true,
	canRestore			= false,
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
		price			= 5085,
		heatlimit 		= 10,
		armor			= 6,
		squadsize 		= 1,
		wheels			= true,
		support			= true,
	},
}

return lowerkeys({
	["Salvager"] = Salvager:New(),
})