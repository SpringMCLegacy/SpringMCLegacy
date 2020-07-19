local IS_DroST = Unit:New{ -- TODO: better base class than Unit
	name              	= "DroST II Landing Craft",
	description         = "Cargo Landing Craft",
	objectName        	= "Dropship/DroST.s3o",
	iconType			= "drost",
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
			name	= "AC10",
			maxAngleDif = 100,
		},
		[2] = {
			name	= "LBL",
			maxAngleDif = 100,
		},
		[3] = {
			name	= "LBL",
			maxAngleDif = 100,
		},
		[4] = {
			name	= "MBL",
			maxAngleDif = 100,
		},
		[5] = {
			name	= "NBL",
			maxAngleDif = 100,
		},
	},
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
		dropship		= "outpost",
		hoverheight		= 300,
		radialdist		= 2500,
		ignoreatbeacon	= true,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

dropShips = {}
for i, sideName in pairs(Sides) do
	dropShips[sideName .. "_drost"] = IS_DroST:New{}
end
return lowerkeys(dropShips)