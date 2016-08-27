local Corsair = Aero:New{
	name              	= "Corsair",
	description         = "Air Superiority",
	turnRadius		= 2000,
	maxAcc			= 0.22,
	maxBank			= 0.0006,
	maxPitch		= 0.0006,
	maxAileron		= 0.004,
	maxElevator		= 0.004,
	maxRudder		= 0.002,
	wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,
	
	weapons = {	
		[1] = {
			name	= "ERLBL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "ERLBL",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "MBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "MBL",
			maxAngleDif = 35,
		},
		[5] = {
			name	= "SBL",
			maxAngleDif = 35,
		},
		[6] = {
			name	= "SBL",
			maxAngleDif = 35,
		},
		[7] = {
			name	= "SBL",
			maxAngleDif = 35,
		},
		[8] = {
			name	= "SBL",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		tonnage			= 50,
		variant         = "CSR-V14",
		speed			= 400,
		price			= 9450,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 13.5},
		squadsize 		= 2,
    },
}

return lowerkeys({ 
	["FS_Corsair"] = Corsair:New{},
})