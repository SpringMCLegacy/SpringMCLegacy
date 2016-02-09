local IS_Avenger = {
	name              	= "Avenger-Class Dropship",
	description         = "Prefab Delivery Dropship",
	objectName        	= "IS_Avenger.s3o",
	iconType			= "dropship",
	script				= "Dropship.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000,
	mass                = 36000,
	footprintX			= 20,
	footprintZ 			= 20,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	movementClass		= "LARGEMECH", -- herp
	power				= 1, -- don't target me!
	
	-- Transport tags
	transportSize		= 8,
	transportCapacity	= 8, -- 1x transportSize
	transportMass		= 10000,
	holdSteady			= true,
	--minTransportMass	= 10000,

	--Makes unit use weapon from /weapons folder
	--[[weapons	= {	

	},]]
	--Gets CEG effects from /gamedata/explosions folder
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
		dropship		= "upgrade",
		flagdefendrate  = 100,
		hoverheight		= 300,
		radialdist		= 2500,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({["IS_Avenger"] = IS_Avenger})