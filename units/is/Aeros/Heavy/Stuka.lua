local Stuka = Aero:New{
	name              	= "Stuka",
	description         = "Heavy Aerofighter",
	
	buildPic			= "FS_Stuka.png", -- TODO: remove in future
	
	acceleration       = 0.30,
	maxAcc             = 1.18,
	turnRadius         = 105,
	wingDrag           = 0.06,
	wingAngle          = 0.08,
	crashDrag          = 0.005,
	maxBank            = 0.72,
	maxPitch           = 0.6,
	verticalSpeed      = 4.0,
	maxAileron         = 0.024,--13,
	maxElevator        = 0.024,--13,
	maxRudder          = 0.0042,--22,

	radardistance	= 1500,
	
	customparams = {
		tonnage			= 100,
		speed			= 230 * 1.75, --2160
		heatlimit 		= 40,
		armor			= 16,
		squadsize 		= 2,
		
		entryDelay 		= 30,
		prepDelay 		= 45,
		
    },
}

local STUD6 = Stuka:New{
	
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
			name	= "LBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "LBL",
			maxAngleDif = 35,
		},
		[5] = {
			name	= "MBL",
			maxAngleDif = 35,
		},
		[6] = {
			name	= "MBL",
			maxAngleDif = 35,
			mainDir = [[0 0 -1]],
		},
		[7] = {
			name	= "MBL",
			maxAngleDif = 35,
			mainDir = [[0 0 -1]],
		},
		[8] = {
			name	= "AirLRM20",
			maxAngleDif = 35,
		},
		[9] = {
			name	= "AirLRM20",
			maxAngleDif = 35,
		},
		[10] = {
			name	= "A2AArrow",
			maxAngleDif = 35,
			onlyTargetCategory = "air",
		},
		
	},
	
	customparams = {
		variant         = "STU-D6",
		price			= 18380,
		heatlimit 		= 40,
		armor			= 16,
		squadsize 		= 2,
		maxammo 		= {lrm = 2, arrow = 0.8},
		strafeDistance  = 500, -- how close to get to target while strafing
		strafeOvertime  = 1000, -- how long to keep flying over target after strafing
		
    },
}


return lowerkeys({
	["DC_Stuka_STUD6"] = STUD6:New(),
	["CC_Stuka_STUD6"] = STUD6:New(),
	["FS_Stuka_STUD6"] = STUD6:New(),
	["FW_Stuka_STUD6"] = STUD6:New(),
	["LA_Stuka_STUD6"] = STUD6:New(),
})