local Avenger = Aero:New{
	name              	= "Avenger",
	description         = "Assault Dropship",
	objectName        	= "dropship/Avenger.s3o",
	buildPic			= "Dropship_Avenger.png", -- TODO: remove in future
	iconType			= "avenger",
	script				= "Dropship.lua",
	--category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 30000,
	mass                = 36000,
	radardistance		= 1500,
	footprintX			= 20,
	footprintZ 			= 20,
	canMove				= true,
	canAttack			= true,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	power				= 36000,
	
	canFly				= true,
	--hoverAttack			= true,
	cruiseAlt			= 350,
	--airHoverFactor		= 0.8,
	maxVelocity			= 20,--5,
	
	--turnRadius		= 1000,
	--maxAcc			= 0.18,
		--maxBank			= 0.95, -- default 0.8
	--maxPitch		= 0.0007,
		--maxAileron		= 0.05, -- default 0.015
	--maxElevator		= 0.004,
		--maxRudder		= 0.0008, -- default 0.004
	--[[wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,]]

acceleration       = 0.25,
maxAcc             = 0.7,
turnRadius         = 160,
wingDrag           = 0.07,
wingAngle          = 0.07,
crashDrag          = 0.005,
maxBank            = 0.45,
maxPitch           = 0.4,
verticalSpeed      = 2.5,
maxAileron         = 0.008,
maxElevator        = 0.008,
maxRudder          = 0.0015,

	usepiececollisionvolumes 	= false,

	weapons 		= {	
		-- Chin Turret
		[1] = {
			name	= "AirAC20",
		},
		[2] = {
			name	= "AC5",
			--slaveTo = 1,
		},
		[3] = {
			name	= "AC5",
			slaveTo = 2,
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
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
			slaveTo = 4,
		},
		-- Right Cheek Turret
		[6] = {
			name	= "LBL",
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
		},
		[7] = {
			name	= "ERMBL",
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
			slaveTo = 6,
		},
		-- Left Wing AC5s
		[8] = {
			name	= "AC5",
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
		},
		[9] = {
			name	= "AC5",
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
			slaveTo = 8,
		},
		-- Right Wing AC5s
		[10] = {
			name	= "AC5",
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
		},
		[11] = {
			name	= "AC5",
			mainDir = "0 -1 1",
			maxAngleDif = 40, --20,
			slaveTo = 10,
		},
		--Left Wing
		[12] = {
			name	= "ERMBL",
			mainDir = "0 -1 1",
			maxAngleDif = 45,
		},
		[13] = {
			name	= "PPC",
			mainDir = "0 -1 1",
			maxAngleDif = 40,--20,
		},
		--Right Wing
		[14] = {
			name	= "ERMBL",
			mainDir = "0 -1 1",
			maxAngleDif = 45,
		},
		[15] = {
			name	= "PPC",
			mainDir = "0 -1 1",
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
			name 	= "bomb",
		},
		--[23] = {
		--	name 	= "sight",
		--},
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
		--dropship		= "assault", -- for script info
		hoverheight		= 350,--300,
		radialdist		= 5000, --2500,
		ignoreatbeacon	= true,
		--sectorangle		= 30,
		baseclass		= "aero",
		entryDelay 		= 45,
		prepDelay 		= 60,
		spawnAtTarget	= true,
		speed			= 252 * 1.75, -- 2520
		price      		= 36000,
		maxfuel 		= 45,
		unlocklevel 	= 2,
		cockpitheight	= 25.23,
    },
}

aeros = {}
for i, sideName in pairs(Sides) do
	aeros[sideName .. "_avenger"] = Avenger:New{}
end
-- Avenger is IS only!
aeros["wf_avenger"] = nil
aeros["sj_avenger"] = nil
return lowerkeys(aeros)