local Corsair = Aero:New{
	name              	= "Corsair",
	description         = "Medium Fighter Bomber",
	
	buildPic			= "fs_corsair.png", -- TODO: remove in future
	
	acceleration       = 0.32,
	maxAcc             = 1.18,
	turnRadius         = 105,
	wingDrag           = 0.05,
	wingAngle          = 0.08,
	crashDrag          = 0.005,
	maxBank            = 0.72,
	maxPitch           = 0.6,
	verticalSpeed      = 4.0,
	maxAileron         = 0.024,--13,
	maxElevator        = 0.024,--13,
	maxRudder          = 0.0042,--22,
	
	--[[acceleration       = 0.35,
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
	maxRudder          = 0.0018,]]
	
	radardistance	= 1500,
	
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
		speed			= 250 * 1.75, --2160
		price			= 9450,
		heatlimit 		= 32,
		armor			= 13.5,
		squadsize 		= 2,
		maxammo 		= {bomb = 5},
		
		entryDelay 		= 15,
		prepDelay 		= 20,
		
    },
}


aeros = {}
for i, sideName in pairs(Sides) do
	aeros[sideName .. "_corsair"] = Corsair:New{}
end
-- Corsair is IS only!
aeros["wf_corsair"] = nil
aeros["sj_corsair"] = nil
return lowerkeys(aeros)