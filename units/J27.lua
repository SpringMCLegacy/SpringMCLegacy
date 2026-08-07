local J27 = Tank:New{
	name              	= "J-27 Ordnance Transport",
	description         = "Resupply Vehicle - Supplies ammunition to mechs on the frontline.",
	trackWidth			= 27,--width to render the decal
	
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 5,
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
		normaltex		= "unittextures/normals/J-27_Normals.dds",
		support			= true,
	},
}

return lowerkeys({
	["J27"] = J27:New(),
})