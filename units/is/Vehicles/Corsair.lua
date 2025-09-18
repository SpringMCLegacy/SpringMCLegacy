local Corsair = Aero:New{
	name              	= "Corsair",
	description         = "Medium Fighter Bomber",
	buildCostMetal	= 16000,
	buildPic			= "fs_corsair.png", -- TODO: remove in future
	
	acceleration       = 0.35,
	maxAcc             = 0.9,
	turnRadius         = 110,
	wingDrag           = 0.065,
	wingAngle          = 0.075,
	crashDrag          = 0.005,
	maxBank            = 0.65,
	maxPitch           = 0.5,
	verticalSpeed      = 3.2,
	maxAileron         = 0.010,
	maxElevator        = 0.010,
	maxRudder          = 0.0018,

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
		speed			= 6 * 60,
		price			= 9450,
		heatlimit 		= 32,
		armor			= 2,
		squadsize 		= 2,
		maxammo 		= {bomb = 5},
    },
}


aeros = {}
for i, sideName in pairs(Sides) do
	aeros[sideName .. "_corsair"] = Corsair:New{}
end
aeros["wf_corsair"] = nil -- Corsair is IS only!
return lowerkeys(aeros)