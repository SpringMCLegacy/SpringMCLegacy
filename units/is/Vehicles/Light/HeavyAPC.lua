local HeavyAPC = LightTank:New{
	name              	= "Heavy APC",
	description			= "Troop Transport",
	
	transportCapacity		= 5,
	transportSize = 1,	
	trackWidth			= 18,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "MG",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "MG",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 20,
		variant         = "",
		speed			= 80,
		price			= 4130,
		heatlimit 		= 10,
		armor			= 4,
		barrelrecoildist = {[1] = 4},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_HeavyAPC"] = HeavyAPC:New(),
	["DC_HeavyAPC"] = HeavyAPC:New(),
	["FW_HeavyAPC"] = HeavyAPC:New(),
	["FS_HeavyAPC"] = HeavyAPC:New(),
	["LA_HeavyAPC"] = HeavyAPC:New(),
})