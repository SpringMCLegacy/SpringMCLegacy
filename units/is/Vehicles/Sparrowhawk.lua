local Sparrowhawk = Aero:New{
	name              	= "Sparrowhawk",
	description         = "Light Interceptor",
	turnRadius		= 1000,
	maxAcc			= 0.18,
	maxBank			= 0.0007,
	maxPitch		= 0.0007,
	maxAileron		= 0.0045,
	maxElevator		= 0.004,
	maxRudder		= 0.002,
	wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,
	
	weapons = {	
		[1] = {
			name	= "MPL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "MPL",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "ERMBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "ERMBL",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "SPR-7D",
		speed			= 400,
		price			= 9450,
		heatlimit 		= 20,
		armor			= 2,
		squadsize 		= 2,
    },
}

return lowerkeys({ 
	["FS_Sparrowhawk"] = Sparrowhawk:New{},
})