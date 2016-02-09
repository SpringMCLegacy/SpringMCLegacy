local IS_DroST = {
	name              	= "DroST II Landing Craft",
	description         = "Cargo Landing Craft",
	objectName        	= "IS_DroST.s3o",
	iconType			= "dropship",
	script				= "Dropship.lua",
	category 			= "ground notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 13000,
	mass                = 13000,
	footprintX			= 20,
	footprintZ 			= 20,
	--collisionVolumeType = "ellipsoid",
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	movementClass		= "LARGEMECH", -- herp
	usePieceCollisionVolumes = true,
	power				= 1, -- don't target me!
	
	-- Transport tags
	transportSize		= 8,
	transportCapacity	= 64, -- 1x transportSize
	transportMass		= 1000000,
	holdSteady 			= true,

	--Makes unit use weapon from /weapons folder
	weapons	= {	
		[1] = {
			name	= "AC5",
			maxAngleDif = 200,
			mainDir = [[0 1 0]],
		},
		[2] = {
			name	= "AC5",
			maxAngleDif = 200,
			mainDir = [[0 1 0]],
		},
		[3] = {
			name	= "AC5",
			maxAngleDif = 200,
			mainDir = [[0 -1 0]],
		},
		[4] = {
			name	= "AC5",
			maxAngleDif = 200,
			mainDir = [[0 -1 0]],
		},
		[5] = {
			name	= "AC5",
			maxAngleDif = 30,
		},
		[6] = {
			name	= "LBL",
			maxAngleDif = 30,
		},
		[7] = {
			name	= "LBL",
			maxAngleDif = 30,
		},
		[8] = {
			name	= "LBL",
			maxAngleDif = 30,
			mainDir = [[-1 0 0]],
		},
		[9] = {
			name	= "ERMBL",
			maxAngleDif = 30,
		},
		[10] = {
			name	= "ERNBL",
			maxAngleDif = 30,
		},
		[11] = {
			name	= "ERMBL",
			maxAngleDif = 30,
			mainDir = [[-1 0 0]],
		},
	},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
			--"custom:heavy_jet_trail",
			"custom:dropship_main_engine_stage2",
		},
	},
	customparams = {
		helptext		= "A Dropship",
		dropship		= "vehicle",
		hoverheight		= 43 + 12,
		radialdist		= 2500,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({["IS_DroST"] = IS_DroST})