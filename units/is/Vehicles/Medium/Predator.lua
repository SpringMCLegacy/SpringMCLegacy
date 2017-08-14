local Predator = LightTank:New{
	name              	= "Predator",
	description			= "Medium Brawler Tank",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "AC20",
			maxAngleDif = 15,
		},
	},
	
	customparams = {
		tonnage			= 45,
		variant         = "",
		speed			= 80,
		price			= 4800,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 4.5},
		maxammo 		= {ac20 = 1},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_Predator"] = Predator:New(),
})