local IS_MarkVII = DropShip:New{
	name              	= "Mark VII Landing Craft",
	description         = "Cargo Landing Craft",
	iconType			= "markvii",
	maxDamage           = 10000,
	mass                = 13000,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	canMove				= true,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	usePieceCollisionVolumes = true,

	--Makes unit use weapon from /weapons folder
	weapons	= {	
		[1] = {
			name	= "SBL",
			maxAngleDif = 10,
		},
		[2] = {
			name	= "SBL",
			maxAngleDif = 10,
		},
		[3] = {
			name	= "MBL",
			maxAngleDif = 10,
			--mainDir = [[-1 0 0]],
		},
		[4] = {
			name	= "MBL",
			maxAngleDif = 10,
			--mainDir = [[-1 0 0]],
		},
		[5] = {
			name	= "MBL",
			maxAngleDif = 10,
			--mainDir = [[1 0 0]],
		},
		[6] = {
			name	= "MBL",
			maxAngleDif = 100,
			--mainDir = [[1 0 0]],
		},
		[7] = {
			name	= "MBL",
			maxAngleDif = 10,
			mainDir = [[0 0 -1]],
		},
		[8] = {
			name	= "MBL",
			maxAngleDif = 10,
			mainDir = [[0 0 -1]],
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
		ignoreatbeacon	= true,
		normaltex		= "unittextures/normals/MarkVII_Normals.dds"
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

dropShips = {}
for i, sideName in pairs(Sides) do
	dropShips[sideName .. "_dropship_markvii"] = IS_MarkVII:New{}
end
return lowerkeys(dropShips)