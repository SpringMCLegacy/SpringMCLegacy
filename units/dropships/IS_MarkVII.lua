local IS_MarkVII = {
	name              	= "Mark VII Landing Craft",
	description         = "Cargo Landing Craft",
	objectName        	= "IS_MarkVIIb.s3o",
	iconType			= "dropship",
	script				= "Dropship_MarkVII.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000,
	mass                = 36000,
	footprintX			= 20,
	footprintZ 			= 20,
	--collisionVolumeType = "ellipsoid",
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	energyStorage		= 0.01,
	metalMake			= 400,
	metalStorage		= 50000,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	movementClass		= "LARGEMECH", -- herp
	usePieceCollisionVolumes = true,
	-- Transport tags
	transportSize		= 8,
	transportCapacity	= 64, -- 1x transportSize
	transportMass		= 1000000,
	holdSteady 			= true,

	--Makes unit use weapon from /weapons folder
	weapons	= {	

	},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
			"custom:heavy_jet_trail_blue",
			"custom:medium_jet_trail_blue",
			"custom:heavy_jet_trail",
			"custom:dropship_main_engine_stage2",
		},
	},
	customparams = {
		helptext		= "A Dropship",
		dropship		= true,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({["IS_MarkVII"] = IS_MarkVII})