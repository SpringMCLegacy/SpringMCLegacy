local Lightning = Aero:New{
	name              	= "Lightning",
	description         = "Attack Aerofighter",
	
	buildPic			= "lightning.png", -- TODO: remove in future
	
	acceleration       = 0.28,
	maxAcc             = 1.18,
	turnRadius         = 115,
	wingDrag           = 0.05,
	wingAngle          = 0.08,
	crashDrag          = 0.005,
	maxBank            = 0.70,
	maxPitch           = 0.65,
	verticalSpeed      = 3.8,
	maxAileron         = 0.024,--13,
	maxElevator        = 0.024,--13,
	maxRudder          = 0.0042,--22,

	radardistance	= 1500,
	
	customparams = {
		tonnage			= 50,
		speed			= 200 * 1.75, --2160
		heatlimit 		= 32,
		armor			= 10.5,
		squadsize 		= 2,
		
		entryDelay 		= 20,
		prepDelay 		= 30,
		
    },
}

local LTNG15 = Lightning:New{
	
	weapons = {	
		[1] = {
			name	= "AirAC20",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "MBL",
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
			name	= "MBL",
			maxAngleDif = 35,
			mainDir = [[0 0 -1]],
		},
	},
	customparams = {
		variant         = "LTN-G15",
		price			= 10930,
		heatlimit 		= 32,
		armor			= 10.5,
		squadsize 		= 2,
		maxammo 		= {ac20 = 2},
		
		strafeDistance  = 300, -- how close to get to target while strafing
		strafeOvertime  = 1000, -- how long to keep flying over target after strafing
    },
}

local LTNG16D = Lightning:New{

	weapons	= {	
		[1] = {
			name	= "RAC2",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "RAC2",
			maxAngleDif = 35,
			SlaveTo = 1,
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
			name	= "ERMBL",
			maxAngleDif = 35,
		},
		[6] = {
			name	= "ERMBL",
			maxAngleDif = 35,
			mainDir = [[0 0 -1]],
		},
		[7] = {
			name	= "MPL",
			maxAngleDif = 35,
		},
		[8] = {
			name	= "MPL",
			maxAngleDif = 35,
		},
	},
		
	customparams = {
		variant         = "LTN-G16D",
		price			= 13280,
		heatlimit 		= 32,
		armor			= 10.5,
		squadsize 		= 2,
		maxammo 		= {ac2 = 5},
		
		strafeDistance  = 500, -- how close to get to target while strafing
		strafeOvertime  = 1000, -- how long to keep flying over target after strafing
    },
}

local LTNG16S = Lightning:New{
	
	weapons = {	
		[1] = {
			name	= "HeavyGauss",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "ERMBL",
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
			name	= "ERMBL",
			maxAngleDif = 35,
			mainDir = [[0 0 -1]],
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
			name	= "ERSBL",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		variant         = "LTN-G16S",
		price			= 16330,
		heatlimit 		= 32,
		armor			= 10.5,
		squadsize 		= 2,
		maxammo 		= {hvgauss = 2},
		
		strafeDistance  = 800, -- how close to get to target while strafing
		strafeOvertime  = 1000, -- how long to keep flying over target after strafing
    },
}

local LTNG16L = Lightning:New{

	weapons = {	
		[1] = {
			name	= "AirUAC20",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "ERMBL",
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
			name	= "ERMBL",
			maxAngleDif = 35,
			mainDir = [[0 0 -1]],
		},
	},
	
	customparams = {
		variant         = "LTN-G16L",
		speed			= 200 * 1.75, --2160
		price			= 10930,
		heatlimit 		= 32,
		armor			= 10.5,
		squadsize 		= 2,
		maxammo 		= {ac20 = 3},
		
		strafeDistance  = 300, -- how close to get to target while strafing
		strafeOvertime  = 1000, -- how long to keep flying over target after strafing
    },
}

return lowerkeys({
	["DC_Lightning_LTNG15"] = LTNG15:New(),
	["CC_Lightning_LTNG16L"] = LTNG16L:New(),
	["FS_Lightning_LTNG16D"] = LTNG16D:New(),
	["FW_Lightning_LTNG15"] = LTNG15:New(),
	["LA_Lightning_LTNG16S"] = LTNG16S:New(),
})