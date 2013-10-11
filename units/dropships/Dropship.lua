local Dropship = {
	name              	= "Dropship",
	description         = "Lance Delivery Dropship",
	objectName        	= "Dropship.s3o",
	iconType			= "dropship",
	script				= "Dropship_fx.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000,
	mass                = 36000,
	footprintX			= 20,
	footprintZ 			= 20,
	collisionVolumeType = "ellipsoid",
	idleAutoHeal		= 0,
	transportSize		= 8,
	transportCapacity	= 80, -- 10x transportSize
	transportMass		= 100000,
	holdSteady 			= true,

	weapons 		= {	
			--[[[1] = {
				name	= "AC10",
				mainDir = "0 1 1",
				maxAngleDif = 180,
			},
			[2] = {
				name	= "AC10",
				mainDir = "0 1 1",
				maxAngleDif = 180,
			},
			[3] = {
				name	= "AC10",
				mainDir = "1 1 0",
				maxAngleDif = 180,
			},
			[4] = {
				name	= "AC10",
				mainDir = "1 1 0",
				maxAngleDif = 180,
			},
			[5] = {
				name	= "AC10",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
			},
			[6] = {
				name	= "AC10",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
			},
			[7] = {
				name	= "AC10",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
			},
			[8] = {
				name	= "AC10",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
			},
			[9] = {
				name	= "PPC",
				mainDir = "0 1 1",
				maxAngleDif = 180,
			},
			[10] = {
				name	= "PPC",
				mainDir = "1 1 0",
				maxAngleDif = 180,
			},
			[11] = {
				name	= "PPC",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
			},
			[12] = {
				name	= "PPC",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
			},
			[13] = {
				name	= "LRM15",
				mainDir = "1 1 1",
				maxAngleDif = 180,
			},
			[14] = {
				name	= "LRM15",
				mainDir = "1 1 -1",
				maxAngleDif = 180,
			},
			[15] = {
				name	= "LRM15",
				mainDir = "-1 1 -1",
				maxAngleDif = 180,
			},
			[16] = {
				name	= "LRM15",
				mainDir = "-1 1 1",
				maxAngleDif = 180,
			},
			[17] = {
				name	= "ERMBL",
				mainDir = "0 1 1",
				maxAngleDif = 180,
			},
			[18] = {
				name	= "ERMBL",
				mainDir = "0 1 1",
				maxAngleDif = 180,
			},
			[19] = {
				name	= "ERMBL",
				mainDir = "1 1 0",
				maxAngleDif = 180,
			},
			[20] = {
				name	= "ERMBL",
				mainDir = "1 1 0",
				maxAngleDif = 180,
			},
			[21] = {
				name	= "ERMBL",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
			},
			[22] = {
				name	= "ERMBL",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
			},
			[23] = {
				name	= "ERMBL",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
			},
			[24] = {
				name	= "ERMBL",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
			},
			[25] = {
				name	= "LBL",
				mainDir = "1 1 1",
				maxAngleDif = 180,
			},
			[26] = {
				name	= "LBL",
				mainDir = "1 1 -1",
				maxAngleDif = 180,
			},
			[27] = {
				name	= "LBL",
				mainDir = "-1 1 -1",
				maxAngleDif = 180,
			},
			[28] = {
				name	= "LBL",
				mainDir = "-1 1 1",
				maxAngleDif = 180,
			},
			[29] = {
				name	= "AMS_Dropship",
			},]]
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:PPC_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		"custom:dropship_main_engine_stage2",
		"custom:dropship_main_engine_stage3",
		"custom:dropship_heavy_dust",
		"custom:heavy_jet_trail",
		"custom:heavy_jet_trail_blue",
		"custom:dropship_reentry",
		},
	},
	customparams = {
		helptext		= "A Dropship",
		hasbap			= true,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({
	["IS_Dropship"] = Dropship,
	["CL_Dropship"] = Dropship,
})