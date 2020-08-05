local Corsair = Aero:New{
	name              	= "Corsair",
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
			name	= "LBL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "LBL",
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
		[5] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[6] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[7] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[8] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[9] = {
			name	= "Bomb",
		}
	},
	
	customparams = {
		tonnage			= 50,
		variant         = "CSR-V14",
		speed			= 700,
		price			= 9450,
		heatlimit 		= 32,
		armor			= {type = "standard", tons = 2},
		squadsize 		= 2,
		maxammo 		= {bomb = 5},
    },
}


aeros = {}
for i, sideName in pairs(Sides) do
	aeros[sideName .. "_corsair"] = Corsair:New{}
end
return lowerkeys(aeros)