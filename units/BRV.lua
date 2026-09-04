local BRV = Support:New{
	name              	= "Heavy BRV",
	description         = "Support Vehicle - Loads an entire wreck and deposits it at the salvage yard for recovery or scrapping.",
	trackWidth			= 37,--width to render the decal
	
	holdSteady = true,
	--weapons	= {	
	--},
	
	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 10170,
		heatlimit 		= 10,
		armor			= 6,
		squadsize 		= 1,
		hitchmaxy		= 60,
		uniformbin		= "treads2k",
		turretturnspeed	= 25,
		elevationspeed	= 25,
		cratetype		= "cratelong",
		normaltex		= "unittextures/normals/Oppie_Normals.dds",
		texmod 			= "player",
	},
}

return lowerkeys({
	["BRV"] = BRV:New(),
})