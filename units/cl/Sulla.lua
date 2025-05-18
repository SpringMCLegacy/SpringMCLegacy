local Sulla = Aero:New{
	name              	= "Sulla",
	description         = "Air Superiority",
	turnRadius		= 1000,
	maxAcc			= 0.5,
	maxBank			= 0.01,
	maxPitch		= 0.007,
	maxAileron		= 0.007,
	maxElevator		= 0.007,
	maxRudder		= 0.007,
	wingAngle		= 0.2,
	wingDrag		= 0.1,
	myGravity		= 0.5,
	speedToFront	= 0.01,
	radardistance	= 1500,
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "CERPPC",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "CERPPC",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "Bomb",
		}
	},
	
	customparams = {
		tonnage			= 45,
		variant         = "Prime",
		speed			= 700,
		price			= 9450,
		heatlimit 		= 32,
		armor			= 2,
		squadsize 		= 2,
		maxammo 		= {bomb = 2},
    },
}


aeros = {}
aeros["wf_sulla"] = Sulla:New{}
return lowerkeys(aeros)