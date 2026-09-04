local Savior = Support:New{
	name              	= "Savior Repair Vehicle",
	description         = "Repair Vehicle - Repairs mechs on the frontline.",
	trackWidth			= 27,--width to render the decal
	
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 5,
	holdSteady = true,
	weapons	= {	
		[1] = {
			name	= "SBL",
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 60,
		price			= 8900,
		heatlimit 		= 10,
		armor			= 1,
		squadsize 		= 1,
		--mods			= {"ferrofibrousarmour"},
		hitchmaxy		= 60,
		normaltex		= "unittextures/normals/Savior_Normals.dds",
		texmod 			= "player",
	},
}

return lowerkeys({
	["Savior"] = Savior:New(),
})