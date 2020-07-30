local IS_Avenger = {
	name              	= "Avenger-Class Dropship",
	description         = "Assault Dropship",
	objectName        	= "IS_Avenger2.s3o",
	iconType			= "avenger",
	script				= "Dropship.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 30000,
	mass                = 36000,
	radardistance		= 1500,
	footprintX			= 20,
	footprintZ 			= 20,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	canAttack			= true,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	movementClass		= "LARGEMECH", -- herp
	power				= 1, -- don't target me!
	
	canFly				= true,
	hoverAttack			= true,
	cruiseAlt			= 350,
	airHoverFactor		= 0.8,
	maxVelocity			= 5,
	
	--turnRadius		= 1000,
	--maxAcc			= 0.18,
	maxBank			= 0.95, -- default 0.8
	--maxPitch		= 0.0007,
	maxAileron		= 0.05, -- default 0.015
	--maxElevator		= 0.004,
	maxRudder		= 0.0008, -- default 0.004
	--[[wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,]]
	
	-- Transport tags
	--[[transportSize		= 8,
	transportCapacity	= 8, -- 1x transportSize
	transportMass		= 10000,
	holdSteady			= true,]]
	--minTransportMass	= 10000,

	weapons 		= {	
		-- Chin Turret
		[1] = {
			name	= "AirAC20",
		},
		[2] = {
			name	= "AC5",
			slaveTo = 1,
		},
		[3] = {
			name	= "AC5",
			slaveTo = 1,
		},
		-- Left Cheek Turret
		[4] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 40,--20,
			slaveTo = 3,
		},
		[5] = {
			name	= "ERMBL",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
			slaveTo = 4,
		},
		-- Right Cheek Turret
		[6] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
		},
		[7] = {
			name	= "ERMBL",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
			slaveTo = 6,
		},
		-- Left Wing AC5s
		[8] = {
			name	= "AC5",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
		},
		[9] = {
			name	= "AC5",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
			slaveTo = 8,
		},
		-- Right Wing AC5s
		[10] = {
			name	= "AC5",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
		},
		[11] = {
			name	= "AC5",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
			slaveTo = 10,
		},
		--Left Wing
		[12] = {
			name	= "ERMBL",
			mainDir = "0 0 1",
			maxAngleDif = 45,
		},
		[13] = {
			name	= "PPC",
			mainDir = "0 0 1",
			maxAngleDif = 40,--20,
		},
		--Right Wing
		[14] = {
			name	= "ERMBL",
			mainDir = "0 0 1",
			maxAngleDif = 45,
		},
		[15] = {
			name	= "PPC",
			mainDir = "0 0 1",
			maxAngleDif = 40, --20,
		},
		--Rear
		[16] = {
			name	= "ERMBL",
			mainDir = "0 0 -1",
			maxAngleDif = 45,
		},
		[17] = {
			name	= "ERMBL",
			mainDir = "0 0 -1",
			maxAngleDif = 45,
		},
		--LRMs
		[18] = {
			name	= "AirLRM20",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[19] = {
			name	= "AirLRM20",
			mainDir = "1 0 1",
			maxAngleDif = 90,
		},
		[20] = {
			name	= "AirLRM20",
			mainDir = "-1 0 1",
			maxAngleDif = 90,
		},
		[21] = {
			name	= "AirLRM20",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[22] = {
			name 	= "ptab",
		},
		[23] = {
			name 	= "sight",
		},
	},
	sfxtypes = {
		explosiongenerators = {
			"custom:heavy_jet_trail_blue",
			"custom:medium_jet_trail_blue",
			"custom:dropship_main_engine_stage2",
			"custom:heavy_jet_trail",
		},
	},
	customparams = {
		helptext		= "A Dropship",
		--dropship		= "outpost",
		flagdefendrate  = 100,
		hoverheight		= 150,--300,
		radialdist		= 5000, --2500,
		ignoreatbeacon	= true,
		sectorangle		= 30,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({["IS_Avenger"] = IS_Avenger})